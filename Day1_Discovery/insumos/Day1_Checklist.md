# Activity Checklist - Day 1: Discovery & Blueprinting

## 1. Pre-session Preparation

- [X] Review the "Playbook" document and understand the objectives.
- [X] Review the "Blueprint" template (MASTER CX Blueprint).
- [X] Review the assigned use case (Case 1: Global Fintech Company).
- [X] Read the `Discovery_Questions.md` file and familiarize yourself with the questions to ask.

## 2. During the Discovery Session (Workshop)

- [X] **Introduction and Commercial Review (See Kickoff_Script.md):**
  - [X] Thank the customer for purchasing the subscription via Reseller.
  - [X] Review the subscription metrics (API Calls, Gateway Services, AI Calls, AI Models) and the acquired Konnect modules.
  - [X] Explain the onboarding to Kong Support and introduce the CX contact.
- [X] **Architecture & Infrastructure:** Ask about network topology, EKS/GKE usage, and High Availability (HA) requirements.
- [X] **Platform Security (Konnect):** Define the identity provider for Admin SSO and the RBAC model.
- [X] **API Security:** Define the Identity Provider (e.g., Ping, Keycloak) for the OIDC flow for consumers (Partners/Apps).
- [X] **AI Use Cases:** Clarify the LLM provider to be used for fraud analysis and logging/compliance requirements.
- [X] **Traffic Control:** Define required Rate Limiting and Caching policies.
- [X] **Automation (APIOps):** Confirm CI/CD tools (GitHub Actions) and where the OpenAPI Specifications (OAS) reside.
- [X] **Observability:** Confirm the use of Prometheus and Grafana for Data Plane metrics.

## 3. Individual Work (Documentation)

- [X] **Create the Architecture Diagram:** Use Lucidchart to draw the Control Plane, Data Plane, IdP integrations, and upstream services (Accounts, Transactions, LLM).
- [X] **Complete the Blueprint:** Fill out the `Blueprint_Draft.md` document with all the architectural and technical decisions agreed upon during the Discovery.
- [X] **Final Review:** Ensure the Blueprint covers all the requirements of the Fintech Case before moving on to Day 2 implementation.
