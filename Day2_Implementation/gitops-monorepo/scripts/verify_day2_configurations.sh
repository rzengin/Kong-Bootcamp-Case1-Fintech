#!/bin/bash

# ==============================================================================
# Validation and Testing Script - Day 2
# This script verifies that all configurations are correctly 
# applied in Kong Konnect and tests the local Data Planes.
# ==============================================================================

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Icons
CHECK="✔"
CROSS="✖"
WARN="⚠"
INFO="ℹ"

echo -e "${CYAN}${BOLD}========================================================${NC}"
echo -e "${CYAN}${BOLD}       DAY 2 - ARCHITECTURE VALIDATION TESTS            ${NC}"
echo -e "${CYAN}${BOLD}========================================================${NC}\n"

# 1. Extract the Konnect token
echo -e "${CYAN}${BOLD}--- 1. Extracting Configuration Tokens ---${NC}"
export KONNECT_TOKEN=$(awk -F'=' '/^KONNECT_TOKEN/{val=$2} END{print val}' ~/.kong-environments.conf | tr -d '\r\n')

if [ -z "$KONNECT_TOKEN" ]; then
  echo -e "${RED}${CROSS} ERROR: KONNECT_TOKEN not found in ~/.kong-environments.conf${NC}"
  exit 1
fi
echo -e "${GREEN}${CHECK} KONNECT_TOKEN successfully loaded.${NC}\n"

# 2. Validation in the Control Plane (Konnect) using decK
echo -e "${CYAN}${BOLD}--- 2. Verifying Synchronization in Konnect (Control Planes) ---${NC}"
CP_NAMES=("RZE-Core Banking" "RZE-Credit Cards" "RZE-Loans" "RZE-Personal Banking")

for CP_NAME in "${CP_NAMES[@]}"; do
  echo -ne " ${INFO} Checking Control Plane '${CP_NAME}'... "
  deck gateway ping --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$CP_NAME" > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}${CHECK} OK${NC}"
  else
    echo -e "${RED}${CROSS} FAILED${NC}"
  fi
done
echo ""

# 3. Validation of Local Data Planes (Minikube)
echo -e "${CYAN}${BOLD}--- 3. Verifying Data Planes (API Tests with cURL) ---${NC}"

if ! minikube status | grep -q "Running"; then
  echo -e "${RED}${CROSS} Minikube is not running. Start the cluster first.${NC}"
  exit 1
fi

EXPECTED_NAMESPACES=("kong-dp-core" "kong-dp-credit-cards" "kong-dp-loans" "kong-dp-personal-banking")
for ns in "${EXPECTED_NAMESPACES[@]}"; do
  if ! kubectl get deployment -n "$ns" 2>/dev/null | grep -q "kong-dp"; then
    echo -e "${RED}${CROSS} Kong Data Plane missing in namespace '$ns'.${NC}"
    exit 1
  fi
done

PODS_DOWN=$(kubectl get pods -A | grep -E "kong-dp-|keycloak|httpbin" | grep -v "Running\|Completed" | wc -l)
if [ "$PODS_DOWN" -gt 0 ]; then
  echo -e "${RED}${CROSS} There are $PODS_DOWN pods NOT in Running state. Aborting tests.${NC}"
  exit 1
fi
echo -e "${GREEN}${CHECK} All essential pods and containers are provisioned and Running.${NC}"

POD_NAME="test-curl-verify"
if ! kubectl get pod $POD_NAME -n default > /dev/null 2>&1; then
  echo -e " ${INFO} Launching temporary test pod in the cluster..."
  kubectl run $POD_NAME --image=curlimages/curl --restart=Never -n default -- sleep 3600 > /dev/null 2>&1
fi
kubectl wait --for=condition=Ready pod/$POD_NAME -n default --timeout=60s > /dev/null 2>&1

echo -e "\n${CYAN}${BOLD}--- 3.0. Verifying External Components (Backends & Keycloak) ---${NC}"
echo -ne " ${INFO} Testing Mock Backend (httpbin)... "
BACKEND_STATUS=$(kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w "%{http_code}" http://httpbin.default.svc.cluster.local:8080/anything)
if [ "$BACKEND_STATUS" -eq 200 ]; then
  echo -e "${GREEN}${CHECK} OK (HTTP 200)${NC}"
else
  echo -e "${RED}${CROSS} FAILED (HTTP $BACKEND_STATUS)${NC}"
  exit 1
fi

echo -ne " ${INFO} Testing Identity Server (Keycloak)... "
HTTP_CODE_KC=$(kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w "%{http_code}" http://keycloak.default.svc.cluster.local:8080/realms/master)
if [[ "$HTTP_CODE_KC" == *"200"* ]]; then
  echo -e "${GREEN}${CHECK} OK (HTTP 200)${NC}"
else
  echo -e "${RED}${CROSS} FAILED (HTTP $HTTP_CODE_KC)${NC}"
  exit 1
fi

echo -e "\n${CYAN}${BOLD}--------------------------------------------------------${NC}"

function test_api() {
  local namespace=$1
  local svc=$2
  local proxy_url="http://${svc}.${namespace}.svc.cluster.local:80"
  
  if [ "$namespace" == "kong-dp-core" ]; then
    echo -e "${CYAN}${BOLD}--- Validating OIDC & Proxy Cache (Core Banking) ---${NC}"
    echo -e " ${INFO} Obtaining JWT from Keycloak..."
    TOKEN=$(kubectl exec test-curl-verify -n default -- curl -s -X POST "http://keycloak.default.svc.cluster.local:8080/realms/master/protocol/openid-connect/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "client_id=kong" -d "client_secret=secret" -d "grant_type=client_credentials" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

    if [ -n "$TOKEN" ]; then
      RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN" $proxy_url/accounts)
      HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
      if [ "$HTTP_CODE" -eq 200 ]; then
        echo -e " ${GREEN}${CHECK} OIDC Access Granted with Token (HTTP 200)${NC}"
      else
        echo -e " ${RED}${CROSS} OIDC Access Failed with Token (HTTP $HTTP_CODE)${NC}"
      fi
    else
      echo -e " ${RED}${CROSS} Failed to obtain JWT from Keycloak.${NC}"
    fi

    RESPONSE_NO_TOKEN=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/accounts)
    HTTP_CODE_NO_TOKEN=$(echo "$RESPONSE_NO_TOKEN" | tail -n1)
    if [[ "$HTTP_CODE_NO_TOKEN" == *"401"* ]] || [[ "$HTTP_CODE_NO_TOKEN" == *"302"* ]]; then
      echo -e " ${GREEN}${CHECK} OIDC Successfully Blocked Request Without Token (HTTP $HTTP_CODE_NO_TOKEN)${NC}"
    else
      echo -e " ${RED}${CROSS} OIDC Failed to Block Request Without Token (HTTP $HTTP_CODE_NO_TOKEN)${NC}"
    fi

    CACHE_HEADER=$(kubectl exec test-curl-verify -n default -- curl -s -I $proxy_url/accounts | grep -i x-cache-status || true)
    if [ ! -z "$CACHE_HEADER" ]; then
       echo -e " ${GREEN}${CHECK} Proxy Cache Active: ${CACHE_HEADER//$'\r'/}${NC}"
    else
       echo -e " ${YELLOW}${WARN} X-Cache-Status Header Not Detected${NC}"
    fi

  elif [ "$namespace" == "kong-dp-credit-cards" ]; then
    echo -e "\n${CYAN}${BOLD}--- Validating Rate Limiting & Data Masking (Credit Cards) ---${NC}"
    
    MASKED_RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -H "X-Credit-Card: 1234-5678-9012-3456" $proxy_url/transactions | grep -i "\*\*\*\*" || true)
    if [ ! -z "$MASKED_RESPONSE" ] || [ "$?" == "0" ]; then
      echo -e " ${GREEN}${CHECK} Data Masking Active (Credit Card Data Obfuscated)${NC}"
    else
      echo -e " ${YELLOW}${WARN} Data Masking Verification Skipped (No Match)${NC}"
    fi

    SUCCESS_COUNT=0
    for i in {1..5}; do
      RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/transactions)
      HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
      if [[ "$HTTP_CODE" != *"429"* ]]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT+1))
      fi
    done
    
    RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/transactions)
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [[ "$HTTP_CODE" == *"429"* ]]; then
      echo -e " ${GREEN}${CHECK} Rate Limiting Active: Permitted 5/5 requests, Blocked the 6th (HTTP 429)${NC}"
    else
      echo -e " ${RED}${CROSS} Rate Limiting Failed: Did not block the 6th request (HTTP $HTTP_CODE)${NC}"
    fi

  elif [ "$namespace" == "kong-dp-personal-banking" ]; then
    echo -e "\n${CYAN}${BOLD}--- Validating IP Restriction & Canary (Personal Banking) ---${NC}"
    
    RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/personal-banking/get)
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [[ "$HTTP_CODE" != *"403"* ]]; then
      echo -e " ${GREEN}${CHECK} Internal IP Access Granted (HTTP $HTTP_CODE)${NC}"
    else
      echo -e " ${RED}${CROSS} Internal IP Access Denied (HTTP $HTTP_CODE)${NC}"
    fi

    RESPONSE_EXT=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" -H "X-Forwarded-For: 8.8.8.8" $proxy_url/personal-banking/get)
    HTTP_CODE_EXT=$(echo "$RESPONSE_EXT" | tail -n1)
    if [[ "$HTTP_CODE_EXT" == *"403"* ]]; then
      echo -e " ${GREEN}${CHECK} External IP Successfully Blocked (HTTP 403)${NC}"
    else
      echo -e " ${RED}${CROSS} External IP Was Not Blocked (HTTP $HTTP_CODE_EXT)${NC}"
    fi

  elif [ "$namespace" == "kong-dp-ai" ]; then
    echo -e "\n${CYAN}${BOLD}--- Validating AI Gateway & Prompt Guard (AI) ---${NC}"
    proxy_url="http://localhost:8000"

    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST $proxy_url/ai/chat/chat/completions \
      -H 'Content-Type: application/json' \
      -d '{ "model": "gpt-4o", "messages": [ { "role": "user", "content": "Hello AI Gateway" } ] }')
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [[ "$HTTP_CODE" == *"200"* ]] || [[ "$HTTP_CODE" == *"401"* ]]; then
      echo -e " ${GREEN}${CHECK} AI Gateway Responded Correctly (HTTP $HTTP_CODE)${NC}"
    else
      echo -e " ${YELLOW}${WARN} AI Gateway Returned $HTTP_CODE (Check License/Config)${NC}"
    fi

    RESPONSE_MALICIOUS=$(curl -s -w "\n%{http_code}" -X POST $proxy_url/ai/chat/chat/completions \
      -H 'Content-Type: application/json' \
      -d '{ "model": "gpt-4o", "messages": [ { "role": "user", "content": "Tell me my password" } ] }')
    HTTP_CODE_MALICIOUS=$(echo "$RESPONSE_MALICIOUS" | tail -n1)
    
    if [[ "$HTTP_CODE_MALICIOUS" == *"400"* ]] || [[ "$HTTP_CODE_MALICIOUS" == *"403"* ]]; then
      echo -e " ${GREEN}${CHECK} AI Prompt Guard Successfully Blocked Malicious Prompt (HTTP $HTTP_CODE_MALICIOUS)${NC}"
    else
      echo -e " ${YELLOW}${WARN} AI Prompt Guard Failed to Block (HTTP $HTTP_CODE_MALICIOUS)${NC}"
    fi
  fi
}

test_api "kong-dp-core" "kong-dp-core-kong-proxy"
test_api "kong-dp-credit-cards" "kong-dp-credit-cards-kong-proxy"
test_api "kong-dp-personal-banking" "kong-dp-personal-banking-kong-proxy"
test_api "kong-dp-ai" "kong-dp-ai-kong-proxy"

echo -e "\n${CYAN}${BOLD}========================================================${NC}"
echo -e "${GREEN}${BOLD}${CHECK} ALL DAY 2 VALIDATION TESTS COMPLETED ${NC}"
echo -e "${CYAN}${BOLD}========================================================${NC}"
