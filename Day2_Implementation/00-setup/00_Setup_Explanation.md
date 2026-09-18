# Explicación del Entorno Base (00-setup)

Este documento detalla cada uno de los pasos ejecutados durante la fase inicial de configuración (Día 2) para preparar la infraestructura base necesaria antes de desplegar las APIs y las políticas de Kong.

## 1. Generación de Certificados mTLS (`generate_certs.sh`)
Para que los Data Planes (nodos de ejecución de Kong) puedan conectarse de manera segura al Control Plane en Kong Konnect (SaaS), es estrictamente necesario establecer un túnel **mTLS** (Mutual TLS). 
- El script itera sobre las 5 unidades de negocio (`credit_cards`, `loans`, `personal_banking`, `core`, `ai`).
- Utiliza **OpenSSL** para generar una llave privada (`tls.key`) y un certificado autofirmado (`tls.crt`) válido por 10 años.
- Los guarda en la carpeta local `certs/`. 
- Estos certificados luego se "anclan" (Pinning) en la interfaz de Konnect y se inyectan en Kubernetes para que el Data Plane los use al arrancar.

## 2. Configuración de Variables de Entorno (`setup_environment.sh`)
El entorno de ejecución requiere variables críticas como las URLs de los Control Planes.
- El script exporta las URLs del `cluster_control_plane` y `cluster_telemetry_endpoint` obtenidas desde Konnect para cada uno de los 5 Control Planes lógicos creados.
- Exporta también el endpoint de observabilidad externa (`DECK_SIGNOZ_ENDPOINT`), apuntando a la IP de SigNoz.
- Toda esta configuración se guarda en un archivo `.env` que luego es consumido por Terraform y Helm.

## 3. Despliegue de Keycloak (`setup_keycloak.sh`)
Para manejar la identidad y seguridad de manera centralizada (Zero Trust):
- Se levanta un contenedor de **Keycloak** usando Docker Compose (o se verifica su conexión dentro del clúster).
- Se expone en el puerto `8080`.
- Durante su inicialización, se carga un **Realm** llamado `kong` con clientes preconfigurados para demostrar el flujo de autenticación `client_credentials` utilizado en las llamadas Machine-to-Machine.

## 4. Creación del Clúster y Pods (`deploy_local_k8s.sh`)
Se simula el entorno productivo EKS utilizando Kubernetes local.
1. **Namespaces:** El script crea 5 namespaces totalmente aislados (ej. `kong-dp-core`, `kong-dp-credit-cards`).
2. **Secretos mTLS:** Inyecta los certificados creados en el paso 1 dentro de cada namespace usando `kubectl create secret tls`.
3. **Despliegue Helm:** Usa el chart oficial de Kong (`kong/kong`) para desplegar los Data Planes. 
   - Para las 4 unidades de negocio estándar, despliega la imagen `kong/kong-gateway:3.15.0.6`.
   - Para el namespace `kong-dp-ai`, despliega la imagen especializada `kong/kong-ai-gateway:2.0.3`.
   - A todos les inyecta las variables de entorno conectándolos a su respectivo Control Plane de Konnect.
4. **Mockups & Testing:** Se despliegan pods auxiliares en el namespace por defecto: un contenedor `httpbin` que funciona como backend universal para todas las APIs de prueba, y un pod `test-curl-verify` que usamos luego para inyectar tráfico a la red.

## 5. Configuración de Red (Networking)
- Todo el tráfico de los Data Planes hacia Konnect (CP) se enruta por el puerto `443` hacia el exterior, cifrado con el certificado propio del DP.
- Los Data Planes exponen sus servicios de Proxy (el puerto donde reciben tráfico API) a través de un `LoadBalancer` o NodePort en Kubernetes.
- Los servicios virtuales (`accounts`, `transactions`) mapean al backend en `http://httpbin.default.svc.cluster.local:8080` utilizando la resolución DNS interna (CoreDNS) de Kubernetes.
