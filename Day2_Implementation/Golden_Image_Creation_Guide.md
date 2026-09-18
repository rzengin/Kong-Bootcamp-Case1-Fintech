# Golden Image Creation Guide (Day 2)

During Day 2, we established our **Golden Image** (base and foundational configuration of the environment) following an orderly process that laid the groundwork for subsequent automation via GitOps (APIOps).

Below is the exact sequence of steps we followed to build this foundation:

## Phase 1: Underlying Infrastructure (On-Premise / Local)
Before interacting with Kong, we prepared the ground where our Data Planes would live:
1. **Cluster Provisioning:** We started the Kubernetes cluster (`minikube` / Docker Desktop).
2. **Dependency Deployment (Mock):** We installed `httpbin` in the cluster to simulate the bank's core transactional systems.
3. **Security Deployment (IdP):** We installed **Keycloak** in the cluster, creating the realm and client needed to issue OIDC (Client Credentials) tokens.
4. **Observability Deployment:** We installed the **Signoz (OpenTelemetry)** stack via Helm to be ready to receive metrics and traces.

## Phase 2: Foundational Configuration in Kong Konnect (The real "Golden Image")
The next step was to create the base state in the Kong SaaS (Control Plane):
1. **Workspaces Creation (Control Planes):** From the Konnect UI, we created logically isolated environments for each Business Unit (BUs): *Core, Credit Cards, Loans, Personal Banking, and AI Gateway*.
2. **mTLS Certificates Generation:** For each Control Plane, we generated the necessary certificate and key pairs (Cert/Key) from Konnect so the Data Planes can authenticate securely.
3. **Secrets Storage:** We stored these certificates as `Secrets` within our local Kubernetes cluster, in the corresponding namespaces (`kong-dp-core`, `kong-dp-ai`, etc.).

## Phase 3: Data Planes Deployment (Nodes)
With Konnect ready to receive connections, we deployed the "muscles" of the Gateway:
1. **Helm Installation:** We used the official Kong chart to deploy the Data Planes in Kubernetes.
2. **Secrets Association:** We configured the Helm `values.yaml` files to mount the mTLS certificates generated in the previous step.
3. **Successful Connection:** We verified that the Data Planes were `Online` in the Konnect UI.

## Phase 4: Export and APIOps Adoption (GitOps)
This is where the magic happens. Once we had the Golden Image of the base infrastructure, we moved to govern the lifecycle of the APIs:
1. **Initial Synchronization:** Instead of creating Services and Routes manually in Konnect, we used the Swagger (OAS) design files from Day 1.
2. **Kong decK Usage:** We converted those files to declarative configuration and executed `deck sync` towards Konnect.
3. **Plugins Injection:** At the code level (YAML), we associated the plugins to the corresponding BUs:
   - `openid-connect` (connected to local Keycloak) for *Core*.
   - `rate-limiting` for *Credit Cards*.
   - `proxy-cache-advanced` for *Loans*.
   - `opentelemetry` configured globally to export to Signoz.

## Phase 5: AI Gateway Configuration (Manual Golden Image)
Since the **AI Gateway 2.0 (Semantic Routing)** is a native and novel feature handled mainly via UI in Konnect (instead of the legacy `ai-proxy` plugin from Kong 1.x), this part of the setup was performed manually as part of the Golden Image:
1. **AI Providers:** We configured OpenAI credentials (API Keys) directly in Konnect's secure vault.
2. **AI Models:** We registered the specific models to use (`gpt-4`, `gpt-3.5-turbo`).
3. **Semantic Routing:** We created semantic routing rules in the UI so that chatbot requests were correctly routed.
4. **AI Prompt Guard:** We enabled the plugin (with regular expressions) on the semantic route to block the transmission of confidential information (credit card numbers) to the LLMs.

---
**Conclusion:** Upon finishing this sequence, our *Golden Image* (Control Planes + Nodes + Base Configuration + AI) was established. Any future transactional change (new routes, new plugins) simply flows through our CI/CD pipeline (APIOps) using `decK`, without requiring manual intervention in the graphical interface, except for the native management of the AI Gateway.
