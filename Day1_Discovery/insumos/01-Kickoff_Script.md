# Kickoff Script - Subscription Review (Day 1)

*This script/key points should be used at the beginning of the Day 1 session (Discovery Workshop) to demonstrate proactivity and commercial/technical control to the Kong evaluators.*

## 0. Context: Case Details Communicated by Kong
*Before the meeting, we acknowledge the background information provided by Kong regarding the client's current situation:*
- **Client:** Global Fintech Company.
- **Current Landscape:** Highly siloed operations across Credit Cards, Loans, and Personal Banking units. Legacy core systems are causing bottlenecks and high latency during traffic spikes.
- **Strategic Goals:** Modernize architecture, improve Developer Experience (DX), and drastically accelerate B2B partner onboarding.
- **AI Initiative:** The client wants to adopt LLMs (e.g., OpenAI) for Fraud Analysis, but requires strict safeguards to prevent the leakage of sensitive data (PII, Credit Card numbers) to public models.
- **Security & Traffic Needs:** Immediate need for OIDC authentication, Rate Limiting to protect legacy backends, and Proxy-Caching to alleviate system load.

## 1. Welcome and Appreciation
- "Hello team! Thank you so much for your time today. Before we dive into the architecture of your Accounts, Payments, and Transactions APIs, we wanted to do a quick administrative review."
- "As you know, you acquired the Kong subscription through us (as resellers), and we have made sure the licensing covers exactly what you need for this modernization and the AI use case."

## 2. Review of Prior Assessment and Sizing (Simulation)
- "Based on the commercial sizing we discussed and finalized last month, I wanted to quickly confirm the parameters of your **Kong Konnect** subscription to ensure we are completely aligned today:"
  - **API Gateway:** You acquired a volume-based tier for **10 million monthly API Calls** and up to **10 Gateway Services**. This was calculated based on the traffic metrics you provided us for your 10 core APIs (Accounts, Transactions, Payments, Open Banking Consent, Loans, Card Issuance, Customer Onboarding, Fraud Analysis, Partner Statement, Support Chatbot).
  - **AI Gateway:** For your Fraud Analysis use case, the subscription includes the AI Gateway add-on sized for **1 million monthly AI Calls** (representing about 10% of your total API traffic requiring fraud checks) and exactly **2 AI Models**. This allows you to configure your primary cloud LLM provider and a secondary fallback or local model for resilience and cost-optimization.
  - **Included Modules:** All the enterprise-grade plugins we identified as critical are enabled: `rate-limiting-advanced` (for your partner tiers), `proxy-cache-advanced`, and access to the managed **Dev Portal** to securely expose your APIs.

- "We have also mapped your acquired metrics: 10M API Calls/month, up to 10 Gateway Services, and 1M AI Calls/month across 2 AI Models. Everything is within bounds for your initial rollout."
- "Since Konnect manages the Control Plane, you have the freedom to deploy as many nodes (Data Planes) as you need in your Kubernetes cluster to guarantee High Availability (HA) without any node-based licensing restrictions."

## 3. Support Onboarding and Customer Experience
- "For us, it is vital that you not only have the technology, but also the operational backing. We want to formally introduce you to the support model."
- "As part of your Konnect subscription, you have access to 24x7 support for critical incidents (P1)."
- **Action to take:** "During this week, we will put you in direct contact with your **Customer Success Manager (CSM)** and the Kong **Customer Experience (CX)** team. They will be responsible for:"
  1. Creating your official users in the [Kong Support Portal](https://support.konghq.com/).
  2. Sharing the escalation matrix.
  3. Setting up quarterly follow-up meetings (EBRs) to ensure you are getting the maximum value out of the platform.

## 4. Transition to Workshop
- "Do you have any questions about the subscription or support channels before we move on to drawing the architecture in Lucidchart?"
