# Discovery Questions - Case 1: Global Fintech Company

## 1. Identity & Security (OAuth / OIDC)
- Which Identity Provider (IdP) is the company currently using for their internal systems and third-party partners?
- Do we need to integrate with an existing Keycloak instance, or should we set up a new Kong Identity / Keycloak environment for this MVP?
- Are there different authentication flows required for Mobile Apps vs. 3rd-party Fintech partners?

## 2. Traffic Management & Rate Limiting
- What are the expected traffic volumes for the Accounts, Payments, and Transactions APIs?
- Do we need tiered rate limiting (e.g., Bronze, Silver, Gold) for different consumers (Internal Analytics vs. 3rd-party partners)?
- Are there any specific SLAs we need to enforce per consumer?

## 3. High Availability (HA) & Architecture
- What are the High Availability requirements for the Data Plane? 
- Will the deployment be multi-region, or single-region with multiple availability zones?
- Are there specific latency requirements we need to consider?

## 4. AI Gateway & Fraud Analysis
- Which LLM provider (e.g., OpenAI, AWS Bedrock, Cohere) is being used for the AI-powered fraud analysis?
- What are the specific compliance and logging requirements for AI usage (e.g., redacting PII, logging prompts/responses)?
- Do we need to enforce token-based rate limiting or cost control for the LLM calls?

## 5. APIOps & CI/CD
- What CI/CD tools (e.g., GitHub Actions, GitLab CI) are currently used by the development teams?
- Where are the OpenAPI Specifications (OAS) currently stored, and how are they versioned?

## 6. Observability
- Do you have an existing Prometheus/Grafana stack, or do you expect Kong Konnect to provide the primary dashboarding capabilities?
- What specific metrics (e.g., latency, error rates, AI token usage) are critical for the business stakeholders?

## 7. Developer Portal
- What is the onboarding process for 3rd-party fintech partners? Do they require manual approval before accessing the APIs?
- Are there specific branding requirements for the private Developer Portal?
