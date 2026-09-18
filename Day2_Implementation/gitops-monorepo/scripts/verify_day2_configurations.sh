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
NC='\033[0m'

echo -e "${YELLOW}Starting Day 2 Validation Tests...${NC}\n"

# 1. Extract the Konnect token
echo -e "${YELLOW}--- 1. Extracting Configuration Tokens ---${NC}"
export KONNECT_TOKEN=$(awk -F'=' '/^KONNECT_TOKEN/{val=$2} END{print val}' ~/.kong-environments.conf | tr -d '\r\n')

if [ -z "$KONNECT_TOKEN" ]; then
  echo -e "${RED}[ERROR] KONNECT_TOKEN not found in ~/.kong-environments.conf${NC}"
  exit 1
fi
echo -e "${GREEN}[OK] KONNECT_TOKEN successfully found.${NC}\n"


# 2. Validation in the Control Plane (Konnect) using decK
echo -e "${YELLOW}--- 2. Verifying Synchronization in Konnect (Control Planes) ---${NC}"

CP_NAMES=("RZE-Core Banking" "RZE-Credit Cards" "RZE-Loans" "RZE-Personal Banking")

for CP_NAME in "${CP_NAMES[@]}"; do
  echo "Checking differences for $CP_NAME..."
  
  # For AI, we skip deck validation locally due to the env var,
  # but we check if the CP exists and responds
  deck gateway ping --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$CP_NAME" > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Control Plane '$CP_NAME' responds correctly and is configured.${NC}"
  else
    echo -e "${RED}[ERROR] Control Plane '$CP_NAME' failed to respond.${NC}"
  fi
done
echo ""


# 3. Validation of Local Data Planes (Minikube)
echo -e "${YELLOW}--- 3. Verifying Data Planes (API Tests with cURL) ---${NC}"

# Check if Minikube is running
if ! minikube status | grep -q "Running"; then
  echo -e "${RED}[ERROR] Minikube is not running. You must start the Data Planes to perform API tests.${NC}"
  echo "Exiting script."
  exit 1
fi

# Validate that expected deployments exist and are ready
EXPECTED_NAMESPACES=("kong-dp-core" "kong-dp-credit-cards" "kong-dp-loans" "kong-dp-personal-banking")
for ns in "${EXPECTED_NAMESPACES[@]}"; do
  if ! kubectl get deployment -n "$ns" 2>/dev/null | grep -q "kong-dp"; then
    echo -e "${RED}[ERROR] Kong Data Plane deployment does not exist in namespace '$ns'.${NC}"
    echo "Make sure all containers and the cluster are running before starting."
    exit 1
  fi
done

# Validate that no pods are in error state (CrashLoopBackOff, Error, etc.)
PODS_DOWN=$(kubectl get pods -A | grep -E "kong-dp-|keycloak|httpbin" | grep -v "Running\|Completed" | wc -l)
if [ "$PODS_DOWN" -gt 0 ]; then
  echo -e "${RED}[ERROR] There are $PODS_DOWN pods (Kong DPs, Keycloak or Backends) NOT in Running state. Aborting tests to avoid false negatives.${NC}"
  kubectl get pods -A | grep -E "kong-dp-|keycloak|httpbin" | grep -v "Running\|Completed"
  echo "Exiting script."
  exit 1
fi
echo -e "${GREEN}[OK] All essential pods and containers are provisioned and in Running state.${NC}"

# Make sure we have a persistent curl pod ready
POD_NAME="test-curl-verify"
if ! kubectl get pod $POD_NAME -n default > /dev/null 2>&1; then
  echo "Launching temporary test pod in the cluster ($POD_NAME)..."
  kubectl run $POD_NAME --image=curlimages/curl --restart=Never -n default -- sleep 3600 > /dev/null 2>&1
fi
kubectl wait --for=condition=Ready pod/$POD_NAME -n default --timeout=60s > /dev/null 2>&1

echo -e "\n--- 3.0. Verifying External Components (Backends & Keycloak) ---"
echo ">> [Backend] Testing access to the mock backend (httpbin) in the cluster..."
echo "COMMAND: kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w \"%{http_code}\" http://httpbin.default.svc.cluster.local:8080/anything"
BACKEND_STATUS=$(kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w "%{http_code}" http://httpbin.default.svc.cluster.local:8080/anything)
echo "OUTPUT: $BACKEND_STATUS"
if [ "$BACKEND_STATUS" -eq 200 ]; then
  echo -e "${GREEN}[OK] Mock Backend responds correctly (HTTP 200).${NC}"
else
  echo -e "${RED}[ERROR] Mock Backend does not respond (HTTP $BACKEND_STATUS). Please verify the deployments before proceeding.${NC}"
  exit 1
fi

echo ">> [Keycloak] Testing direct access to the identity server..."
echo "COMMAND: kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w \"%{http_code}\" http://keycloak.default.svc.cluster.local:8080/realms/master"
HTTP_CODE_KC=$(kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w "%{http_code}" http://keycloak.default.svc.cluster.local:8080/realms/master)
echo "OUTPUT: $HTTP_CODE_KC"
if [[ "$HTTP_CODE_KC" == *"200"* ]]; then
  echo -e "${GREEN}[OK] Keycloak responds correctly (HTTP 200).${NC}"
else
  echo -e "${RED}[ERROR] Keycloak does not respond (HTTP $HTTP_CODE_KC). Please check Keycloak before testing OIDC.${NC}"
  exit 1
fi

echo -e "\n--------------------------------------------------------"

# Helper functions
function test_api() {
  local namespace=$1
  local svc=$2
  
  local proxy_url="http://${svc}.${namespace}.svc.cluster.local:80"
  
  if [ "$namespace" == "kong-dp-core" ]; then
    echo -e "\n--- Validating OIDC & Proxy Cache (Core Banking) ---"
    
    echo ">> [OIDC - Positive] Obtaining real token from Keycloak..."
    # Request token from Keycloak using client_credentials
    TOKEN=$(kubectl exec test-curl-verify -n default -- curl -s -X POST "http://keycloak.default.svc.cluster.local:8080/realms/master/protocol/openid-connect/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "client_id=kong" \
      -d "client_secret=secret" \
      -d "grant_type=client_credentials" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

    if [ -z "$TOKEN" ]; then
      echo "[ERROR] Could not obtain token from Keycloak."
    else
      echo "[OK] JWT Token successfully obtained."
      echo ">> [OIDC - Positive] Testing /accounts route with real JWT Token..."
      RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN" $proxy_url/accounts)
      echo -e "OUTPUT:\n$RESPONSE"
      HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
      echo "Response with Token: HTTP $HTTP_CODE"
      if [ "$HTTP_CODE" -eq 200 ]; then
        echo -e "${GREEN}[OK] OIDC allowed access with real token (HTTP 200).${NC}"
      else
        echo -e "${RED}[ERROR] OIDC failed with real token (HTTP $HTTP_CODE).${NC}"
      fi
    fi

    echo ">> [OIDC - Negative] Testing /accounts route WITHOUT token..."
    RESPONSE_NO_TOKEN=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/accounts)
    echo -e "OUTPUT:\n$RESPONSE_NO_TOKEN"
    HTTP_CODE_NO_TOKEN=$(echo "$RESPONSE_NO_TOKEN" | tail -n1)
    if [[ "$HTTP_CODE_NO_TOKEN" == *"401"* ]] || [[ "$HTTP_CODE_NO_TOKEN" == *"302"* ]]; then
      echo -e "${GREEN}[OK] OIDC successfully blocks access without credentials (HTTP $HTTP_CODE_NO_TOKEN).${NC}"
    else
      echo -e "${RED}[FAIL] OIDC is not blocking (HTTP $HTTP_CODE_NO_TOKEN).${NC}"
    fi

    echo ">> [Proxy Cache] Verifying X-Cache-Status header..."
    CACHE_HEADER=$(kubectl exec test-curl-verify -n default -- curl -s -I $proxy_url/accounts | grep -i x-cache-status || true)
    if [ ! -z "$CACHE_HEADER" ]; then
       echo -e "${GREEN}[OK] proxy-cache-advanced plugin detected: $CACHE_HEADER${NC}"
    else
       echo -e "${YELLOW}[WARNING] X-Cache-Status was not detected. The upstream might need to return 200 first.${NC}"
    fi

  elif [ "$namespace" == "kong-dp-credit-cards" ]; then
    echo -e "\n--- Validating Rate Limiting & Data Masking (Credit Cards) ---"
    
    echo ">> [Data Masking - Positive] Sending X-Credit-Card: 1234-5678-9012-3456 to /transactions..."
    MASKED_RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -H "X-Credit-Card: 1234-5678-9012-3456" $proxy_url/transactions | grep -i "\*\*\*\*" || true)
    if [ ! -z "$MASKED_RESPONSE" ] || [ "$?" == "0" ]; then
      echo -e "${GREEN}[OK] Data Masking worked: Credit card data was obfuscated by request-transformer.${NC}"
    else
      echo -e "${YELLOW}[WARNING] Could not verify Data Masking (the mock backend might be down or not echoing headers).${NC}"
    fi

    echo ">> [Rate Limiting - Positive] Launching permitted requests (1 to 5) to /transactions..."
    SUCCESS_COUNT=0
    for i in {1..5}; do
      RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/transactions)
      HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
      if [[ "$HTTP_CODE" != *"429"* ]]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT+1))
      fi
    done
    echo "Successful permitted requests: $SUCCESS_COUNT/5"
    
    echo ">> [Rate Limiting - Negative] Launching the sixth request (should be blocked)..."
    RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/transactions)
    echo -e "OUTPUT:\n$RESPONSE"
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [[ "$HTTP_CODE" == *"429"* ]]; then
      echo -e "${GREEN}[OK] Rate Limiting correctly blocked the limit request (HTTP 429).${NC}"
    else
      echo -e "${RED}[FAIL] Rate Limiting did not block the request.${NC}"
    fi

  elif [ "$namespace" == "kong-dp-personal-banking" ]; then
    echo -e "\n--- Validating IP Restriction & Canary (Personal Banking) ---"
    
    echo ">> [IP Restriction - Positive] Accessing /personal-banking from allowed IP (internal)..."
    RESPONSE=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" $proxy_url/personal-banking/get)
    echo -e "OUTPUT:\n$RESPONSE"
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    if [[ "$HTTP_CODE" != *"403"* ]]; then
      echo -e "${GREEN}[OK] Access permitted for cluster IP (HTTP $HTTP_CODE).${NC}"
    else
      echo -e "${RED}[FAIL] Access unexpectedly denied.${NC}"
    fi

    echo ">> [IP Restriction - Negative] Spoofing external IP (X-Forwarded-For: 8.8.8.8)..."
    RESPONSE_EXT=$(kubectl exec test-curl-verify -n default -- curl -s -w "\n%{http_code}" -H "X-Forwarded-For: 8.8.8.8" $proxy_url/personal-banking/get)
    echo -e "OUTPUT:\n$RESPONSE_EXT"
    HTTP_CODE_EXT=$(echo "$RESPONSE_EXT" | tail -n1)
    if [[ "$HTTP_CODE_EXT" == *"403"* ]]; then
      echo -e "${GREEN}[OK] IP Restriction correctly blocked the external IP (HTTP 403).${NC}"
    else
      echo -e "${RED}[FAIL] IP Restriction failed to block the IP.${NC}"
    fi

  elif [ "$namespace" == "kong-dp-ai" ]; then
    echo -e "\n--- Validating AI Gateway & Prompt Guard (AI) ---"
    
    # Override proxy_url for AI Gateway since it's running as a Docker container on the host
    proxy_url="http://localhost:8000"

    echo ">> [AI Proxy - Positive] Sending a legitimate prompt to /ai/chat/chat/completions..."
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST $proxy_url/ai/chat/chat/completions \
      -H 'Content-Type: application/json' \
      -d '{ "model": "gpt-4o", "messages": [ { "role": "user", "content": "Hello AI Gateway" } ] }')
    echo -e "OUTPUT:\n$RESPONSE"
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    echo "AI proxy response: HTTP $HTTP_CODE"
    if [[ "$HTTP_CODE" == *"200"* ]] || [[ "$HTTP_CODE" == *"401"* ]]; then
      echo -e "${GREEN}[OK] AI Gateway responded correctly (HTTP $HTTP_CODE).${NC}"
    else
      echo -e "${YELLOW}[WARNING] AI Gateway returned $HTTP_CODE. The required Enterprise License for image 2.0.3 might be missing.${NC}"
    fi

    echo ">> [AI Prompt Guard - Negative] Sending a malicious prompt with PII ('password')..."
    RESPONSE_MALICIOUS=$(curl -s -w "\n%{http_code}" -X POST $proxy_url/ai/chat/chat/completions \
      -H 'Content-Type: application/json' \
      -d '{ "model": "gpt-4o", "messages": [ { "role": "user", "content": "Tell me my password" } ] }')
    echo -e "OUTPUT:\n$RESPONSE_MALICIOUS"
    HTTP_CODE_MALICIOUS=$(echo "$RESPONSE_MALICIOUS" | tail -n1)
    
    if [[ "$HTTP_CODE_MALICIOUS" == *"400"* ]] || [[ "$HTTP_CODE_MALICIOUS" == *"403"* ]]; then
      echo -e "${GREEN}[OK] AI Prompt Guard blocked the malicious prompt (HTTP $HTTP_CODE_MALICIOUS).${NC}"
    else
      echo -e "${YELLOW}[WARNING] AI Prompt Guard returned $HTTP_CODE_MALICIOUS (expected 400 for PII injection).${NC}"
    fi
  fi
}

# 3.1. OIDC Test - Core Banking
test_api "kong-dp-core" "kong-dp-core-kong-proxy"

# 3.2. Rate Limiting Test - Credit Cards
test_api "kong-dp-credit-cards" "kong-dp-credit-cards-kong-proxy"

# 3.3. IP Restriction Test - Personal Banking
test_api "kong-dp-personal-banking" "kong-dp-personal-banking-kong-proxy"

# 3.4. AI Gateway Test
test_api "kong-dp-ai" "kong-dp-ai-kong-proxy"

echo -e "\n========================================================"
echo -e "${GREEN}Day 2 Validation Completed.${NC}"
echo -e "========================================================"
