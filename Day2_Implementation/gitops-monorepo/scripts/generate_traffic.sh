#!/bin/bash
echo "Generating continuous traffic to test OpenTelemetry in Signoz..."

proxy_core="http://kong-dp-core-kong-proxy.kong-dp-core.svc.cluster.local:80"
TOKEN=$(kubectl exec test-curl-verify -n default -- curl -s -X POST "http://keycloak.default.svc.cluster.local:8080/realms/master/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=kong" -d "client_secret=secret" -d "grant_type=client_credentials" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

echo "Sending traffic to Core Banking..."
for i in {1..15}; do
  kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w "Core Request $i: HTTP %{http_code}\n" -H "Authorization: Bearer $TOKEN" $proxy_core/accounts
  sleep 0.2
done

proxy_cc="http://kong-dp-credit-cards-kong-proxy.kong-dp-credit-cards.svc.cluster.local:80"
echo "Sending traffic to Credit Cards..."
for i in {1..10}; do
  kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w "CC Request $i: HTTP %{http_code}\n" $proxy_cc/transactions
  sleep 0.2
done

proxy_pb="http://kong-dp-personal-banking-kong-proxy.kong-dp-personal-banking.svc.cluster.local:80"
echo "Sending traffic to Personal Banking..."
for i in {1..10}; do
  kubectl exec test-curl-verify -n default -- curl -s -o /dev/null -w "PB Request $i: HTTP %{http_code}\n" $proxy_pb/personal-banking/get
  sleep 0.2
done

proxy_ai="http://localhost:8000"
echo "Sending traffic to AI Gateway..."
for i in {1..3}; do
  curl -s -o /dev/null -w "AI Request $i: HTTP %{http_code}\n" -X POST $proxy_ai/ai/chat/chat/completions \
      -H 'Content-Type: application/json' \
      -d '{ "model": "gpt-4o", "messages": [ { "role": "user", "content": "Hello" } ] }'
  sleep 1
done

echo "Massive traffic generated successfully! Check your Signoz dashboard."
