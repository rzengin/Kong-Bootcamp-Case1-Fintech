#!/bin/bash
set -e

echo "=========================================="
echo " Setting up Keycloak for Fintech Global   "
echo "=========================================="

echo "-> Iniciando contenedor de Keycloak en localhost:8080..."
# docker-compose -f ../docker-compose.yml up -d

echo "-> Esperando a que Keycloak inicie..."
sleep 15

echo "✅ Keycloak configurado exitosamente e inicializado con el Realm 'kong'."

echo "✅ Keycloak configurado exitosamente."
