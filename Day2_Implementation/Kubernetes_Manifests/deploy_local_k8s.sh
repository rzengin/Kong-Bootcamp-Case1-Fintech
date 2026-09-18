#!/bin/bash
# Local Kubernetes Deployment Script for Docker Desktop Kubernetes
# Simulates the deployment of 5 isolated Data Planes into 5 namespaces

# Load Konnect endpoints from .env if it exists
if [ -f "../00-setup/.env" ]; then
  source ../00-setup/.env
else
  echo "WARNING: ../00-setup/.env not found! Using dummy endpoints for the demo."
fi

# Define namespaces (which map to our BUs)
NAMESPACES=("kong-dp-credit-cards" "kong-dp-loans" "kong-dp-personal-banking" "kong-dp-core" "kong-dp-ai")

# Ensure Kong Helm repo is added
helm repo add kong https://charts.konghq.com
helm repo update

for ns in "${NAMESPACES[@]}"; do
  echo "Deploying Data Plane in namespace: $ns"
  
  # Map namespace to specific CP variables
  # In a real environment, these would map to different Konnect Control Planes
  case $ns in
    kong-dp-credit-cards)
      CP_URL=${CP_ENDPOINT_CREDIT_CARDS:-"a1b2c3d4e5.us.cp.konghq.com"}
      TP_URL=${TELEMETRY_ENDPOINT_CREDIT_CARDS:-"a1b2c3d4e5.us.tp.konghq.com"}
      BU_DIR="credit_cards"
      ;;
    kong-dp-loans)
      CP_URL=${CP_ENDPOINT_LOANS:-"b1b2c3d4e5.us.cp.konghq.com"}
      TP_URL=${TELEMETRY_ENDPOINT_LOANS:-"b1b2c3d4e5.us.tp.konghq.com"}
      BU_DIR="loans"
      ;;
    kong-dp-personal-banking)
      CP_URL=${CP_ENDPOINT_PERSONAL_BANKING:-"c1b2c3d4e5.us.cp.konghq.com"}
      TP_URL=${TELEMETRY_ENDPOINT_PERSONAL_BANKING:-"c1b2c3d4e5.us.tp.konghq.com"}
      BU_DIR="personal_banking"
      ;;
    kong-dp-core)
      CP_URL=${CP_ENDPOINT_CORE:-"d1b2c3d4e5.us.cp.konghq.com"}
      TP_URL=${TELEMETRY_ENDPOINT_CORE:-"d1b2c3d4e5.us.tp.konghq.com"}
      BU_DIR="core"
      ;;
    kong-dp-ai)
      CP_URL=${CP_ENDPOINT_AI:-"e1b2c3d4e5.us.cp.konghq.com"}
      TP_URL=${TELEMETRY_ENDPOINT_AI:-"e1b2c3d4e5.us.tp.konghq.com"}
      BU_DIR="ai"
      ;;
  esac

  # Strip https:// if present
  CP_URL=${CP_URL#https://}
  TP_URL=${TP_URL#https://}

  # 1. Create the namespace
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
  
  # 2. Create the mTLS secret
  # Assumes generate_certs.sh was run and certs exist
  kubectl create secret tls kong-cluster-cert \
    --cert=../00-setup/certs/$BU_DIR/tls.crt \
    --key=../00-setup/certs/$BU_DIR/tls.key \
    -n $ns --dry-run=client -o yaml | kubectl apply -f -

  if [ "$ns" == "kong-dp-ai" ]; then
    IMAGE_REPO="kong/kong-ai-gateway"
    IMAGE_TAG="2.0.3"
  else
    IMAGE_REPO="kong/kong-gateway"
    IMAGE_TAG="3.15.0.6"
  fi

  # Deploy data plane via Helm
  helm upgrade --install $ns kong/kong -n $ns \
    -f dp-values-template.yaml \
    --set image.repository=$IMAGE_REPO \
    --set image.tag=$IMAGE_TAG \
    --set env.cluster_control_plane=$CP_URL:443 \
    --set env.cluster_telemetry_endpoint=$TP_URL:443 \
    --set env.cluster_server_name=$CP_URL \
    --set env.cluster_telemetry_server_name=$TP_URL
    
  echo "✅ Deployed $ns"
done

echo "=================================================="
echo "All 5 Kubernetes Data Planes deployed to Docker Desktop!"
echo "Run 'kubectl get pods -A' to see them scaling up."
