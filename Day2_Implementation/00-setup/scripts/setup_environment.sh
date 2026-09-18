#!/bin/bash
set -e

echo "=========================================="
echo " Kong Konnect & DP Environment Setup      "
echo "=========================================="

# 1. Generar certificados mTLS
echo "1. Generando certificados mTLS para los Data Planes..."
./generate_certs.sh

# 2. Configurar K8s Secrets para los Data Planes
echo "2. Creando secretos de Kubernetes para los certificados..."
BUs=("credit_cards" "loans" "personal_banking")
for BU in "${BUs[@]}"; do
  echo "-> Creando secret kong-cluster-cert-$BU..."
  # kubectl create secret tls kong-cluster-cert-$BU \
  #  --cert=../certs/$BU/tls.crt \
  #  --key=../certs/$BU/tls.key \
  #  -n kong-$BU --dry-run=client -o yaml > ../certs/$BU/k8s-secret.yaml
done

# 3. Setup Keycloak
echo "3. Ejecutando setup de Keycloak..."
./setup_keycloak.sh

# 4. Levantar Data Planes y Keycloak
echo "4. Para iniciar los Data Planes y Keycloak localmente, asegúrate de tener configurados"
echo "   los endpoints de telemetría y control plane en tu entorno, y luego ejecuta:"
echo ""
echo "   docker-compose up -d"
echo ""

echo "=========================================="
echo " Entorno base (00-setup) preparado.       "
echo " Recuerda cargar los certificados en Konnect"
echo "=========================================="
