# Discovery Questionnaire - Fintech Global Banco

**Date:** September 16, 2026
**Client:** Fintech Global Banco (Roberto Navarro - CTO)

Below are the answers to the discovery questions to better understand our architecture and technical needs:

## 1. Identity & Security (OAuth / OIDC)
- **Which Identity Provider (IdP) is the company currently using for their internal systems and third-party partners?**
  We comply with PCI-DSS and GDPR. We require strict authentication (OIDC/OAuth2) for all services.
- **Do we need to integrate with an existing Keycloak instance, or should we set up a new Kong Identity / Keycloak environment for this MVP?**
  For the PoC/MVP, we will set up a new Keycloak instance to act as our Identity Provider for OIDC flows.
- **Are there different authentication flows required for Mobile Apps vs. 3rd-party Fintech partners?**
  Yes, 3rd-party Fintech partners will need to register and use OIDC Client Credentials flow to access our APIs.

## 2. Traffic Management & Rate Limiting
- **What are the expected traffic volumes for the Accounts, Payments, and Transactions APIs?**
  We currently process around 10 million API calls per month across our 10 core APIs. For the new AI Fraud Analysis use cases, we estimate about 1 million monthly AI calls.
- **Do we need tiered rate limiting (e.g., Bronze, Silver, Gold) for different consumers (Internal Analytics vs. 3rd-party partners)?**
  Yes, we need to enforce strict Rate Limiting per consumer to prevent abuse. Also, our Accounts backend struggles with high read volume, so we need proxy-caching for at least 60 seconds.
- **Are there any specific SLAs we need to enforce per consumer?**
  Our target is < 15ms overhead for standard API routing through the Gateway.

## 3. High Availability (HA) & Architecture
- **What are the High Availability requirements for the Data Plane?**
  We need the Gateway to comfortably handle the 10M+ volume and scale horizontally (up to 10 Gateway Services initially).
- **Will the deployment be multi-region, or single-region with multiple availability zones?**
  We have a hybrid environment. Core Banking remains on-premise, while new digital channels and microservices are hosted on AWS (EKS). We need 5 isolated Data Planes across these environments.
- **Are there specific latency requirements we need to consider?**
  Yes, < 15ms latency overhead as mentioned, plus zero-downtime (Canary) deployments routing e.g., 10% of traffic to v2 before full cutover.

## 4. AI Gateway & Fraud Analysis
- **Which LLM provider (e.g., OpenAI, AWS Bedrock, Cohere) is being used for the AI-powered fraud analysis?**
  We are building a customer service chatbot powered by OpenAI, and an internal credit risk analysis tool using a locally hosted Llama model. We need to abstract the provider so we can switch easily.
- **What are the specific compliance and logging requirements for AI usage (e.g., redacting PII, logging prompts/responses)?**
  Data exfiltration is our biggest fear. We need a central gateway that intercepts all LLM calls and blocks any attempt to send credit card numbers (PII) in prompts.
- **Do we need to enforce token-based rate limiting or cost control for the LLM calls?**
  Yes, we need to track how many tokens each Business Unit consumes to charge them internally (chargeback).

## 5. APIOps & CI/CD
- **What CI/CD tools (e.g., GitHub Actions, GitLab CI) are currently used by the development teams?**
  We use GitHub Actions to automate our pipelines.
- **Where are the OpenAPI Specifications (OAS) currently stored, and how are they versioned?**
  They are stored in Git repositories. We want each of our 3 BUs (Credit Cards, Loans, Personal Banking) to have its own Workspace and self-manage their routes/plugins via APIOps (declarative config) without relying on a central Infrastructure team.

## 6. Observability
- **Do you have an existing Prometheus/Grafana stack, or do you expect Kong Konnect to provide the primary dashboarding capabilities?**
  We expect Konnect to provide a unified dashboard (Vitals) that allows us to view real-time traffic and errors across all BUs in a segmented way, alongside exporting metrics to our own tools.
- **What specific metrics (e.g., latency, error rates, AI token usage) are critical for the business stakeholders?**
  Error rates, latency per BU, and precise AI token usage per provider/BU.

## 7. Developer Portal
- **What is the onboarding process for 3rd-party fintech partners? Do they require manual approval before accessing the APIs?**
  We need a private Developer Portal where external Fintechs can view our API catalogue and securely register their apps (OIDC) without manual intervention from our side.
- **Are there specific branding requirements for the private Developer Portal?**
  Yes, it needs to reflect Fintech Global Banco's corporate branding.
