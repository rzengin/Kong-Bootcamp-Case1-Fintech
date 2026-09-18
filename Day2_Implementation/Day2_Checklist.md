# Activity Checklist - Day 2: Implementation

## 1. Environment Setup

- [X] Connect to Konnect Control Plane.
- [X] Deploy Kubernetes Data Plane (DP) and verify connection to CP.

## 2. APIOps CI/CD Pipeline

- [X] Setup GitHub Repository.
- [X] Create `.github/workflows/deploy.yml` with `deck` commands.
- [X] Add `deck.yaml` declarative configuration or `deck file openapi2kong` step.

## 3. Services & Routes Deployment

- [X] Deploy Accounts Service to Kubernetes (or configure Konnect Service pointing to upstream).
- [X] Deploy Transactions Service to Kubernetes.
- [X] Define routes for each service.
- [X] Verify routing works via Data Plane LoadBalancer IP.

## 4. Security

- [X] Enable Keycloak / Kong Identity in Konnect.
- [X] Configure `openid-connect` plugin globally or per route.
- [X] Test authentication flow with a test consumer.

## 5. Traffic Management Plugins

- [X] Configure `rate-limiting` plugin per consumer.
- [X] Configure `proxy-cache-advanced`.
- [X] Configure `request-transformer` or `response-transformer` (e.g., add/remove headers).

## 6. AI Gateway (Fraud Analysis)

- [X] Configure AI Gateway Semantic Routing (UI) pointing to chosen LLM provider.
- [X] Setup AI logging/metrics.
- [X] Test AI endpoint with mock fraud transaction data.

## 7. Observability

- [X] Deploy OpenTelemetry Collector and connect to external Signoz (194.140.199.236).
- [X] Enable `opentelemetry` plugin in Konnect.
- [X] Access Grafana dashboard and verify Kong metrics are visible.

## 8. Developer Portal

- [X] Enable Konnect Developer Portal.
- [X] Publish Accounts and Transactions API specs to the Portal.
- [X] Setup App Registration to test 3rd-party onboarding.

## 9. Requerimientos Extras / Pruebas de Concepto (PoC)

- [x] **Canary Release:** Crear un `upstream` en una ruta con dos *targets* (peso distinto) para balanceo.
- [x] **WAF (Web Application Firewall):** Demostrar cómo restringir peticiones por IP usando `ip-restriction` plugin o similar.
- [x] **Data Masking:** Ofuscar datos sensibles antes de enviarlos al backend con el plugin `request-transformer` o similar.
- [x] **Seguridad IA:** Bloquear *prompts* peligrosos usando el plugin `ai-prompt-guard`.

## Tareas Finales

- [x] Script de Validación: `gitops-monorepo/scripts/verify_day2_configurations.sh` completo y testeado.
- [x] Actualizar `Final_Blueprint_Day2.md` con las justificaciones, el diseño arquitectónico final y las lecciones aprendidas de la PoC.
