# Inventory of Critical APIs (Top 10) - PoC Candidates

- **From:** Roberto Navarro, CTO - Fintech Global Banco
- **Date:** September 16, 2026

Team, as agreed in our kickoff meeting, here is the list of our Top 10 critical APIs. These are the primary candidates we want to migrate and test during the Proof of Concept (PoC) using Kong and Kong AI Gateway.

## Core Banking APIs (High Traffic / Legacy Integration)
1. **Accounts API (`/v1/accounts`)**
   - **Type:** REST (Read-heavy)
   - **Traffic:** ~4M calls/month
   - **Notes:** Needs aggressive caching and strict OIDC authentication.

2. **Transactions API (`/v1/transactions`)**
   - **Type:** REST
   - **Traffic:** ~3M calls/month
   - **Notes:** High latency currently; we need Kong to improve routing performance.

3. **Payments API (`/v1/payments`)**
   - **Type:** REST (Write-heavy)
   - **Traffic:** ~3M calls/month
   - **Notes:** Mission-critical. Requires highest HA and strict rate limiting to prevent abuse.

## Business Unit Specific APIs
4. **Card Issuance API (`/v1/cards/issue`)**
   - **BU:** Credit Cards
   - **Notes:** Strict PCI-DSS compliance required. Needs data masking in logs.

5. **Loan Origination API (`/v1/loans/apply`)**
   - **BU:** Loans
   - **Notes:** Integrates with third-party credit bureaus.

6. **Customer Onboarding API (`/v1/customers/onboard`)**
   - **BU:** Personal Banking
   - **Notes:** Mobile app consumes this directly. Needs edge protection (WAF integration).

## Open Banking / Partner APIs
7. **Open Banking Consent API (`/v1/consent`)**
   - **BU:** Platform
   - **Notes:** To be exposed via the Developer Portal for 3rd party Fintechs. Requires tiered rate limiting (Gold/Silver/Bronze partners).

8. **Partner Statement Generation API (`/v1/statements`)**
   - **Type:** GraphQL
   - **Notes:** Heavy payload.

## AI Use Cases (Kong AI Gateway Candidates)
9. **Customer Support Chatbot API (`/v1/ai/support-chat`)**
   - **Provider:** OpenAI (Cloud)
   - **Notes:** Must use `ai-proxy`. Needs prompt guarding to prevent users from sharing passwords or credit card info.

10. **Internal Fraud Analysis API (`/v1/ai/fraud-score`)**
    - **Provider:** Local Llama 3 Model (On-premise)
    - **Notes:** Highly sensitive data. Token-based rate limiting required to manage local GPU resources.
