#!/bin/bash
set -e

KONNECT_TOKEN=$(awk -F'=' '/^KONNECT_TOKEN/{val=$2} END{print val}' ~/.kong-environments.conf | tr -d '\r\n')
OPENAI_API_KEY=$(awk -F'=' '/^OPENAI_API_KEY/{val=$2} END{print val}' ~/.kong-environments.conf | tr -d '\r\n')
export DECK_SIGNOZ_ENDPOINT=$(awk -F'=' '/^SIGNOZ_ENDPOINT/{val=$2$3} END{print val}' ~/.kong-environments.conf | tr -d '\r\n')

if [ -z "$KONNECT_TOKEN" ]; then
  echo "Error: KONNECT_TOKEN is not set"
  exit 1
fi

BASE_DIR="../kong-config"

# Iterate over each Business Unit (Control Plane) folder
for BU_DIR in "$BASE_DIR"/*; do
  if [ -d "$BU_DIR" ]; then
    BU_DIR_NAME=$(basename "$BU_DIR")
    echo "Processing Business Unit: $BU_DIR_NAME"
    if [ "$BU_DIR_NAME" == "ai" ]; then
      echo "Skipping AI Gateway directory (managed via UI/kongctl, not decK)."
      continue
    fi
    
    # Map directory names to actual Konnect Control Plane names
    case $BU_DIR_NAME in
      credit_cards) BU_NAME="RZE-Credit Cards" ;;
      loans) BU_NAME="RZE-Loans" ;;
      personal_banking) BU_NAME="RZE-Personal Banking" ;;
      core) BU_NAME="RZE-Core Banking" ;;
      ai) BU_NAME="RZE-AI-Gateway-2.0" ;;
      *) BU_NAME="$BU_DIR_NAME" ;;
    esac
    
    echo "Mapped to Konnect Control Plane: $BU_NAME"
    
    if [ "$BU_DIR_NAME" == "ai" ]; then
      sed -i.bak "s|__OPENAI_API_KEY__|Bearer $OPENAI_API_KEY|g" "$BU_DIR/kong.yaml"
    fi
    
    echo "Generating diff for $BU_NAME Control Plane..."
    deck diff -s "$BU_DIR/kong.yaml" --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$BU_NAME"
    
    echo "Syncing $BU_NAME to Konnect (Control Plane: $BU_NAME)..."
    deck sync -s "$BU_DIR/kong.yaml" --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$BU_NAME"
    
    if [ "$BU_DIR_NAME" == "ai" ]; then
      mv "$BU_DIR/kong.yaml.bak" "$BU_DIR/kong.yaml"
    fi
  fi
done

echo "APIOps Sync completed successfully for all Business Units."
