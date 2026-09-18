# Technical Implementation Summary (Day 2)

This document centralizes all technologies, architectural entities, and Kong plugins used during the implementation phase of the Bootcamp (Case 1: Global Fintech).

---

## 1. Base Infrastructure and Tools

During the development, deployment, and operation lifecycle, the architecture relies on the following foundational technologies:

| Technology / Tool | Project Purpose |
| :--- | :--- |
| **Docker Desktop** | Underlying container engine (especially on macOS) required to mount local clusters and run tools on a bridge network. |
| **Kubernetes / minikube** | Local container orchestrator where we simulate the EKS production environment by isolating workloads in namespaces (`kong-dp-core`, `kong-dp-ai`, etc.). |
| **httpbin** | Deployed as a generic backend service (mock) within the Kubernetes cluster to emulate the responses of the bank's Core systems and transactional APIs. |
| **Helm** | Native Kubernetes package manager used to provision the Data Planes and the observability stack in a standardized and idempotent manner. |
| **OpenTelemetry & Signoz** | Observability and Telemetry Stack. Collects and visualizes distributed traces and latency without requiring instrumentation of the backend applications. |
| **Keycloak** | Third-party Identity Provider (IdP). Deployed in the cluster to issue OIDC Tokens (Client Credentials) validated by Kong. |
| **Bash / Shell Scripts** | Used for pure automation and load testing (`diff-and-apply.sh`, `verify_day2_configurations.sh`, `generate_traffic.sh`). |

---

## 2. Tools, Entities, and Solutions Matrix

To maintain an organized architecture, each tool had a specific purpose and scope depending on the Kong solution involved:

| Tool | Kong Solution | Managed Entities | Use Case in the Project |
| :--- | :--- | :--- | :--- |
| **Terraform** | API Gateway & Konnect (Infra) | `Control Planes`, `RBAC`, `Data Planes` | "Day 1" foundational provisioning. Creation of the Workspaces for the BUs and deployment of the underlying infrastructure. |
| **Kong decK** | API Gateway (APIOps) | `Services`, `Routes`, `Plugins` (OIDC, Rate Limiting) | Declarative lifecycle. Takes the Swagger/OAS and synchronizes the transactional traffic rules in Konnect. |
| **kongctl / Konnect UI** | AI Gateway 2.0 | `AI Providers`, `AI Models`, `Semantic Routes` | Specific AI configuration. Used to abstract OpenAI credentials, configure semantic routing, and tune the `ai-prompt-guard`. |
| **Direct API (REST)** | API Gateway & AI Gateway | `All entities` | Used for quick validations, custom CI/CD integrations, or dynamic configurations that require automation via scripts (curl). |

---

## 3. Kong Entities Used

The implemented architecture uses the core Gateway objects:

- **Control Planes (Workspaces):** Logical isolation environment in Konnect. We created one for each Business Unit (Core, Credit Cards, Loans, Personal Banking, and AI) ensuring strict RBAC.
- **Data Planes (Nodes):** Physical Gateway instances executing the traffic. We deployed hybrid nodes, separating transactional computing from the intensive cluster dedicated to Artificial Intelligence (`kong-ai-gateway`).
- **Services:** Logical representations of the backend applications (e.g., `accounts-service`, pointing to the internal `httpbin` mock).
- **Routes:** Entry rules for client traffic (e.g., `/accounts`, `/ai/chat/chat/completions`).

---

## 4. Enabled Plugins (Kong Ecosystem)

The added value of the implementation was achieved by enabling the following key plugins:

### Security and Access Control
- **`openid-connect` (OIDC):** Configured on the *Core* service to validate JWT tokens issued by Keycloak, abstracting security from the backend.
- **`rate-limiting`:** Applied on the *Credit Cards* service to prevent abuse, limiting bursts and returning an `HTTP 429 Too Many Requests`.

### Traffic and Performance
- **`proxy-cache-advanced`:** Implemented in memory (`strategy: memory`) to store frequent responses and reduce the direct load on the bank's legacy core servers.

### Observability
- **`opentelemetry`:** Enabled globally across all Control Planes to export OTLP traces to our external backend (Signoz), enriched with attributes (`deployment.environment: workshop`).

### Artificial Intelligence (AI Gateway 2.0)
- **Semantic Routing (Core Feature):** Used natively instead of the legacy `ai-proxy` plugin to route generic requests to the configured provider (OpenAI), securely managing credentials (API Keys) in Konnect.
- **`ai-prompt-guard`:** Configured with Regular Expressions (RegEx) for Credit Cards to inspect the payload on the fly and **block** requests attempting to leak PII information to the LLM.

---

## 5. Developer Portal & API Catalog Strategy

En cumplimiento con los requerimientos relevados en la fase de **Discovery (Blueprint)**, la estrategia de publicación de APIs en Kong Konnect sigue un modelo de *Catálogo Unificado pero Portal Segmentado*.

1. **Catálogo de Konnect (Next-Gen Catalog):** 
   Se crearon como *API Packages* las **10 APIs** identificadas en la organización. Todas las especificaciones OpenAPI y documentación fueron cargadas al repositorio central de Konnect para habilitar un inventario global y estandarizado para los equipos internos.

2. **Developer Portal (Exposición Externa):**
   Únicamente se publicaron en el Dev Portal externo las APIs que fueron explícitamente delimitadas para el consumo de *Third-Party Fintech Partners* y que soportan el tráfico core:
   - **Accounts API**
   - **Payments API**
   - **Transactions API**
   - **Open Banking Consent API**
   
   Las demás APIs (ej. Card Issuance, Fraud Analysis, Customer Onboarding) permanecen en estado *Unpublished* en el portal. De esta manera garantizamos que los partners externos solo visualicen y consuman el subconjunto de APIs de *Open Banking* autorizadas para su ecosistema, cumpliendo con el diseño del Blueprint.
