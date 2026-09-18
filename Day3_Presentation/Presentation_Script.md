# Presentation Script - Case 1: Global Fintech Company

## 1. Introduction (The Business Case)
- "Hello stakeholders, today we are presenting the API Gateway implementation for our Global Fintech APIs."
- "Our goal was to securely expose our Accounts, Payments, and Transactions APIs to Mobile Apps, Partners, and Internal systems, while introducing a secure AI Fraud Analysis endpoint."

## 2. Architecture Overview
- Show the Lucidchart diagram.
- Explain the Konnect Control Plane + Kubernetes Data Plane setup.
- Highlight the CI/CD APIOps pipeline that automates deployments.

## 3. Live Demonstration
- **APIOps & Deployment:** Start by showing the execution of `./diff-and-apply.sh` to demonstrate how decK syncs our declarative configuration from the GitOps monorepo to the different Konnect Control Planes.
- **Automated Validation:** Run `./verify_day2_configurations.sh` to automatically test that all endpoints are responding correctly.
- **Security & Rate Limiting:** Show an unauthenticated request failing, then succeeding with a valid OIDC token. Demonstrate how rate limiting kicks in (HTTP 429).
- **AI Gateway (Semantic Routing):** Show the UI configuration of the AI models in Konnect. Send a prompt to the AI endpoint (`/ai/chat/chat/completions`) and show the LLM response. Then, send a prompt containing a credit card number and show how `ai-prompt-guard` blocks it.
- **Observability (OpenTelemetry):** Execute `./generate_traffic.sh` to generate massive parallel traffic. Open **Signoz** and show the live traces and metrics, proving full observability without instrumenting the backend apps.
- **Dev Portal:** Briefly show the custom Developer Portal where partners can view the API specs.

## 4. Future Actions & Outstanding Items
- Outline steps for Kong Operator adoption in EKS.
- Discuss Kong Mesh implementation for internal Zero-Trust security.
- Mention the possibility of building Custom Plugins for highly specific banking logic.
