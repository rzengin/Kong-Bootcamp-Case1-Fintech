# Presentation Slides (Day 3) - Extended Edition

*Instructions: You can copy and generate the PPTX file to present to the Kong evaluators.*

---

## Slide 1: Title Slide
**Title:** Kong Konnect & AI Gateway Implementation
**Subtitle:** Case 1: Global Fintech Bank
**Presenter:** [Your Name] - Solutions Architect

---

## Slide 2: Phase 1 - Discovery and Requirements Mapping
**The Client's Challenge:**
The bank had monolithic architectures and silos, affecting Time to Market and security in the adoption of new technologies.

- **Silos and Bottlenecks:** Credit Cards, Loans, and Personal Banking teams blocked by central infrastructure.
- **Performance:** High latency in core systems under traffic spikes.
- **Security and AI:** Need to adopt LLMs without risk of sensitive data leakage (PII).
- **Developer Experience:** B2B partner onboarding extremely slow.

![](../Day1_Discovery/elaborados/aux/requirements_mapping.png)

---

## Slide 3: Phase 2 - Architecture and Design (Blueprint)
**Hybrid Architecture Optimized for Fintech:**

We decided to separate the control plane (Konnect) from the data plane (EKS), guaranteeing isolation, PCI-DSS compliance, and ultra-low latency.

- **Control Plane in Konnect (SaaS):** Centralized governance (Single Pane of Glass) and strict RBAC.
- **5 Dedicated Data Planes (EKS):** 
  - 4 Transactional Data Planes for isolation between BUs (Cards, Loans, Core, Personal).
  - 1 Dedicated AI Data Plane (`kong-ai-gateway`) to separate token-intensive compute workloads.

![](../Day1_Discovery/elaborados/aux/architecture.png)

---

## Slide 4: Phase 3 - Security and Traffic Implementation
**API-level Governance without touching code:**

- **Rate Limiting:** Implemented in the Cards ecosystem to protect legacy APIs against request spikes (Returning `429 Too Many Requests`).
- **OpenID Connect (OIDC):** Native integration with the bank's Identity Provider (Keycloak) for strict validation of Bearer tokens.
- **Proxy-Cache:** Caching frequent responses to reduce latency of overloaded microservices.

---

## Slide 5: Phase 4 - Secure Artificial Intelligence (AI Gateway)
**Protecting Bank data and controlling costs:**

- **Semantic Routing (UI):** Native semantic routing. Developers just consume `/ai/chat/chat/completions` without touching OpenAI credentials.
- **AI Prompt Guard:** Instant Regular Expressions (RegEx) blocking. If the payload contains credit card formats, the request is blocked *before* reaching the LLM.
- **Costs and Chargeback:** Exact traceability of token consumption (Ingress and Egress) for each Business Unit.

---

## Slide 6: Phase 5 - Operations and Observability (APIOps)
**100% Automation and Centralized Telemetry:**

- **APIOps (decK):** Pipeline based on a GitOps Monorepo. Declarative deployment from Swagger/OAS using the `deck` CLI.
- **OpenTelemetry:** Global OTel plugin integration.
- **Signoz (Backend):** Traces, Logs, and Metrics visualized in real-time without aggressively instrumenting the backend applications.

---

## Slide 7: Live Demonstration
**Architecture Flow in Action:**

1. **APIOps:** Automated deployment and validation of APIs (`verify_day2_configurations.sh`).
2. **Security and Traffic:** Successful OIDC requests and rate limit checks (`Rate Limiting`).
3. **AI in Action:** Successful OpenAI consumption and **real-time blocking** of a credit card by the `ai-prompt-guard`.
4. **Total Visibility:** Massive traffic generation (`generate_traffic.sh`) and live trace monitoring in **Signoz**.

---

## Slide 8: Next Steps (Roadmap)
**The future of the Bank's API Platform:**

- **Kong Operator:** Evolution towards native Kubernetes ingress traffic in the EKS cluster using the modern Gateway API.
- **Kong Mesh:** Service Mesh (mTLS) implementation to guarantee internal Zero-Trust security between core microservices.
- **Custom Plugins (Go/Rust):** Building high-speed plugins for highly specific business logic (e.g., ISO8583 protocol transformations).

---
*End of slides.*
