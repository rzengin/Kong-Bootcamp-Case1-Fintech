#!/bin/bash
set -e

# Script for validating OpenAPI specs using decK
echo "Validating OpenAPI specs..."
for spec in gitops-monorepo/api-specs/openapi-specs/*.yaml; do
  if [ -f "$spec" ]; then
    echo "Validating API config for $BU_NAME Control Plane..."
    deck file openapi2kong -s "$spec" -o /tmp/kong-draft.yaml
    deck validate -s /tmp/kong-draft.yaml --konnect-control-plane-name "$BU_NAME"
  fi
done
echo "OpenAPI validation successful!"
