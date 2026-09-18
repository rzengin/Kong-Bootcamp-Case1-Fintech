# High-Level Architecture Proposal: Multi-BU Control Plane Structure

- **To:** Roberto Navarro, CTO - Fintech Global Banco
- **From:** Ricardo Zengin (Perceptiva)
- **Date:** September 16, 2026

Based on our kickoff meeting and discovery session, here is the proposed high-level architecture using Kong Konnect to support your multi-BU structure while maintaining centralized governance.

## 1. Control Plane (Kong Konnect)
The Control Plane will be hosted on Kong Konnect (SaaS). This provides a single pane of glass for all BUs without the operational overhead of managing the database (PostgreSQL) or control plane nodes.

### Control Plane Structure
To guarantee autonomy and isolation, we will implement the following Control Plane topology:

- **Global Control Plane (Admin/Platform Team):** 
  - Manages global entities such as the Identity Provider (Keycloak/OIDC) configuration, global security plugins (e.g., WAF, global rate limits), and underlying infrastructure connections.
- **BU1 Control Plane: Credit Cards:**
  - Dedicated environment for the Credit Cards team to manage their routes, services, and local rate-limiting policies.
- **BU2 Control Plane: Loans:**
  - Dedicated environment for the Loans team to manage origination and scoring APIs.
- **BU3 Control Plane: Personal Banking:**
  - Dedicated environment for the core banking integration APIs.

*Security Note: Role-Based Access Control (RBAC) will strictly prevent the Credit Cards team from modifying or even viewing the configurations in the Loans Control Plane.*

## 2. Data Plane (Execution Layer)
Since you operate in a hybrid cloud, Kong's Data Planes (DPs) will be deployed where the workloads reside. The DPs pull configurations securely from Konnect via mTLS.

- **AWS EKS Clusters (Cloud):** 5 isolated Data Planes running natively on Kubernetes. Each BU (Credit Cards, Loans, Personal Banking, Core) gets its own DP to prevent port conflicts and noisy-neighbor issues. Crucially, a 5th **Dedicated AI Gateway Data Plane** is deployed to isolate high-latency token generation workloads from standard transactional APIs. These nodes will scale horizontally based on traffic.
- **On-Premise Data Centers:** Dedicated Data Plane nodes placed in front of your legacy Core Banking systems. These nodes ensure that sensitive core traffic doesn't need to trombone through the public cloud just for API Gateway enforcement.

## 3. Developer Portal
A unified Developer Portal will be exposed through Konnect, but API visibility will be segmented. Third-party Fintech partners will only see the APIs they are authorized to consume (e.g., Open Banking APIs).
