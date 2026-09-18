#!/bin/bash
set -e

# Map kong-env variables to Terraform variables
export TF_VAR_konnect_token=$KONNECT_TOKEN
export TF_VAR_demo_prefix=${DEMO_PREFIX:-"RZE"}

# Initialize and apply terraform
terraform init
terraform apply -auto-approve

# Export outputs to the .env file expected by deploy_local_k8s.sh
echo "Generating ../.env file..."
cat <<EOF > ../.env
CP_ENDPOINT_CREDIT_CARDS=$(terraform output -json control_plane_endpoints | jq -r '.credit_cards')
TELEMETRY_ENDPOINT_CREDIT_CARDS=$(terraform output -json telemetry_endpoints | jq -r '.credit_cards')

CP_ENDPOINT_LOANS=$(terraform output -json control_plane_endpoints | jq -r '.loans')
TELEMETRY_ENDPOINT_LOANS=$(terraform output -json telemetry_endpoints | jq -r '.loans')

CP_ENDPOINT_PERSONAL_BANKING=$(terraform output -json control_plane_endpoints | jq -r '.personal_banking')
TELEMETRY_ENDPOINT_PERSONAL_BANKING=$(terraform output -json telemetry_endpoints | jq -r '.personal_banking')

CP_ENDPOINT_CORE=$(terraform output -json control_plane_endpoints | jq -r '.core')
TELEMETRY_ENDPOINT_CORE=$(terraform output -json telemetry_endpoints | jq -r '.core')

CP_ENDPOINT_AI=$(terraform output -json control_plane_endpoints | jq -r '.ai')
TELEMETRY_ENDPOINT_AI=$(terraform output -json telemetry_endpoints | jq -r '.ai')
EOF

echo "✅ ../.env file generated with actual endpoints from Konnect!"
echo "Ahora puedes volver a ejecutar ./deploy_local_k8s.sh en la carpeta Kubernetes_Manifests para que use los endpoints reales."
