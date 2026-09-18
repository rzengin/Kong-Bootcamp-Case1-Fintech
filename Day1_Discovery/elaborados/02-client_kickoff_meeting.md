# Initial Kickoff Meeting Minutes

- **Date:** September 16, 2026
- **Client:** Fintech Global Banco
- **Attendees:** 
  - Roberto Navarro (Architecture Director, Fintech Global Banco)
  - Ricardo Zengin (Solutions Architect, Perceptiva)

***

## 1. Current Client Context
At Fintech Global Banco, we currently have a growing microservices architecture, but our current (legacy) API Gateway has become a bottleneck. We have multiple Business Units (BUs) such as Credit Cards, Loans, and Personal Banking, and each needs to manage its own APIs with some autonomy, but under centralized governance.

## 2. Pain Points
- **Lack of Autonomy:** Development teams in each business unit rely on a central team to publish or modify API policies.
- **Performance:** High latency during peak hours.
- **Visibility:** We lack a unified dashboard that allows us to view real-time traffic and errors across all BUs in a segmented way.
- **AI Adoption:** We want to start integrating Artificial Intelligence models (LLMs) into our API flows securely, and we don't know how our current gateway can support this.
- **Developer Friction:** External partners complain about the slow onboarding process. Frontend teams are blocked when backend systems are down.
- **Traffic Overload & Risk:** Legacy systems are overwhelmed by read traffic, and we have no way to do gradual (Canary) rollouts without risking downtime.

## 3. Migration Objectives (Towards Kong / Kong AI)
- Implement a **multi-BU configuration (Control Planes)** where each unit has its isolated environment, but with corporate security policies (authentication, rate limiting) applied globally.
- Improve performance and reduce latency by utilizing Kong's `proxy-cache-advanced`.
- Establish a **private Developer Portal** for secure partner onboarding and API catalogue management.
- Enable **Canary deployments** and **API Mocking** to accelerate delivery and reduce deployment risks.
- Understand the **advantages of migrating to Kong AI Gateway 2.0** to route traffic to different AI providers, manage usage (tokens), and apply security policies on prompts and responses, using a dedicated AI Data Plane to avoid port conflicts and ensure high performance.

## 4. Next Steps (Action Items)
1. **[Ricardo Zengin - Perceptiva]** Prepare a high-level architecture proposal showing how the Business Units (Workspaces) would be structured in Kong.
2. **[Ricardo Zengin - Perceptiva]** Send a summary of Kong AI Gateway's key capabilities focused on banking security.
3. **[Roberto Navarro]** Share the current inventory of critical APIs (Top 10) that would be candidates for the Proof of Concept (PoC).
4. Schedule a technical deep dive session for next week.

***
*Additional Notes:*
*Roberto emphasized that security and data segregation between BUs is the number one (non-negotiable) requirement to move forward.*
