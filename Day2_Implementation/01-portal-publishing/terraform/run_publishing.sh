#!/bin/bash
set -e

# Always use the token from the file to ensure it's the right one
export KONNECT_TOKEN=$(awk -F'=' '/^KONNECT_TOKEN/{val=$2} END{print val}' ~/.kong-environments.conf | tr -d '\r\n')
export TF_VAR_konnect_token=$KONNECT_TOKEN
export TF_VAR_demo_prefix=${DEMO_PREFIX:-"RZE"}

# Get IDs from the setup terraform state
cd ../../00-setup/terraform
export TF_VAR_portal_id=$(terraform output -raw portal_id)
export TF_VAR_cp_core_id=$(terraform output -json control_plane_ids | jq -r '.core')
export TF_VAR_cp_credit_cards_id=$(terraform output -json control_plane_ids | jq -r '.credit_cards')
export TF_VAR_cp_loans_id=$(terraform output -json control_plane_ids | jq -r '.loans')
cd ../../01-portal-publishing/terraform

echo "Fetching Gateway Service IDs..."
export TF_VAR_svc_accounts_id=$(curl -s -X GET "https://us.api.konghq.com/v2/control-planes/$TF_VAR_cp_core_id/core-entities/services" \
  -H "Authorization: Bearer $KONNECT_TOKEN" | jq -r ".data[] | select(.name == \"accounts-service\") | .id")

export TF_VAR_svc_credit_accounts_id=$(curl -s -X GET "https://us.api.konghq.com/v2/control-planes/$TF_VAR_cp_credit_cards_id/core-entities/services" \
  -H "Authorization: Bearer $KONNECT_TOKEN" | jq -r ".data[] | select(.name == \"transactions-service\") | .id")

export TF_VAR_svc_loans_id=$(curl -s -X GET "https://us.api.konghq.com/v2/control-planes/$TF_VAR_cp_loans_id/core-entities/services" \
  -H "Authorization: Bearer $KONNECT_TOKEN" | jq -r ".data[] | select(.name == \"loans-service\") | .id")

echo "Applying Terraform..."
terraform init
terraform apply -auto-approve
