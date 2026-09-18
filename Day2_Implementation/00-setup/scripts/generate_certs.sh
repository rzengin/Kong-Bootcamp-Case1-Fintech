#!/bin/bash
set -e

echo "=========================================="
echo " Generating mTLS Certs for Kong Konnect   "
echo "=========================================="

BUs=("credit_cards" "loans" "personal_banking" "core" "ai")
BASE_DIR="$(pwd)/../certs"

for BU in "${BUs[@]}"; do
  echo "Generating certificates for $BU Data Plane..."
  BU_DIR="$BASE_DIR/$BU"
  mkdir -p "$BU_DIR"
  
  # Generate Private Key
  openssl genrsa -out "$BU_DIR/tls.key" 2048
  
  # Generate Certificate (self-signed for DP-CP mTLS)
  # In Konnect, this certificate must be pinned in the Control Plane
  openssl req -new -x509 -nodes -sha256 -days 3650 \
    -key "$BU_DIR/tls.key" \
    -out "$BU_DIR/tls.crt" \
    -subj "/C=US/ST=State/L=City/O=Fintech Global/CN=kong-dp-$BU.fintechglobal.com"
    
  echo "✅ Certificates created in $BU_DIR"
done

echo "Done. Remember to upload tls.crt to Konnect Control Plane for each DP."
