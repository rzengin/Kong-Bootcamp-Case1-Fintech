# Kong Konnect Launch Playbook 2.0 - Bootcamp Checklist

This checklist aligns the activities from the official **Kong Konnect Launch Playbook 2.0** with the structure of the Service Delivery Bootcamp (Day 1 and Day 2).

## Day 1: Discovery & Blueprinting (Playbook Chapter 1 & 2)

**Activities:**
- [x] **Introduction & Objectives:** Review the engagement model, customer journey, and business objectives.
- [x] **Discovery Workshop (Part 1):** Cover current/target architecture, Konnect deployment models, Control Plane structure, and Platform Security (SSO, RBAC).
- [x] **Discovery Workshop (Part 2):** Cover API Security (OIDC), Traffic Control, Observability, Automation (APIOps), and initial Use-Case architecture.
- [x] **Infrastructure Planning Workshop:** Size the Dataplane and define the high-availability (HA/DR) architecture.
- [x] **Blueprinting:** Consolidate findings into the initial Blueprint document.

**Deliverables Expected:**
- [x] **Platform Scope & NFRs:** Documented functional and non-functional requirements.
- [x] **Initial API Identified:** Accounts, Payments, and Transactions APIs selected for MVP.
- [x] **Draft Blueprint (Lucidchart + Document):** High-Level Architecture signed off by Kong and the Customer.
- [x] **Infrastructure Architecture & Sizing:** Details for Kubernetes DP deployment.

## Day 2: Implementation & Go-Live (Playbook Chapters 3 - 9 + Appendices)

**Activities:**
- [x] **Chapter 3: Konnect Setup:** Integrate Konnect with IdP (SSO) and map groups to Konnect Teams (RBAC).
- [x] **Chapter 4: Dataplane Build:** Create IaC modules/Helm charts to deploy hardened Kong Data Planes.
- [x] **Chapter 5 & 6: PlatformOps & APIOps:** 
    - Set up the APIOps repo.
    - Create a pipeline to convert OAS to Kong declarative config using `deck`.
- [x] **Appendix: API Security:** Implement and test the OIDC auth flow with the chosen IdP.
- [x] **Chapter 7: Observability Integration:** Configure metrics plugins (Prometheus) and integrate with dashboards (Grafana). Set up Konnect Vitals / Analytics.
- [x] **Appendix: Developer Engagement:** Configure the Developer Portal, set up RBAC, and publish the API specs.
- [x] **Chapter 9: Launch Initial Use Case:** Deploy the Fintech APIs into the environment using the APIOps pipeline and verify traffic.

**Deliverables Expected:**
- [x] **Secured Konnect Account:** With SSO and RBAC mappings in place.
- [x] **IaC Modules:** Scripts/Helm charts used for the DP installation.
- [x] **APIOps Pipeline:** CI/CD pipeline code and repository structure.
- [x] **Codified Plugins (Declarative Config):** YAML/JSON for OIDC, Rate Limiting, Proxy-Cache, and AI Proxy.
- [x] **Reference API Deployed:** The Fintech APIs fully functional and observable in the platform.
- [x] **Themed API Portal:** Developer Portal configured with the published API specifications.
