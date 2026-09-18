# Base Environment Setup Explanation (00-setup)

This document details each of the steps executed during the initial setup phase (Day 2) to prepare the required base infrastructure before deploying the APIs and Kong policies.

## 1. mTLS Certificate Generation (`generate_certs.sh`)
For the Data Planes (Kong execution nodes) to securely connect to the Control Plane in Kong Konnect (SaaS), it is strictly necessary to establish an **mTLS** (Mutual TLS) tunnel.
- The script iterates over the 5 business units (`credit_cards`, `loans`, `personal_banking`, `core`, `ai`).
- It uses **OpenSSL** to generate a private key (`tls.key`) and a self-signed certificate (`tls.crt`) valid for 10 years.
- It saves them in the local `certs/` folder.
- These certificates are then "pinned" in the Konnect interface and injected into Kubernetes for the Data Plane to use upon startup.

## 2. Environment Variables Configuration (`setup_environment.sh`)
The execution environment requires critical variables such as the Control Plane URLs.
- The script exports the `cluster_control_plane` and `cluster_telemetry_endpoint` URLs obtained from Konnect for each of the 5 logical Control Planes created.
- It also exports the external observability endpoint (`DECK_SIGNOZ_ENDPOINT`), pointing to the SigNoz IP.
- All this configuration is saved in a `.env` file that is later consumed by Terraform and Helm.

## 3. Keycloak Deployment (`setup_keycloak.sh`)
To handle identity and security centrally (Zero Trust):
- A **Keycloak** container is spun up using Docker Compose (or its connection is verified inside the cluster).
- It is exposed on port `8080`.
- During initialization, a **Realm** named `kong` is loaded with preconfigured clients to demonstrate the `client_credentials` authentication flow used in Machine-to-Machine calls.

## 4. Cluster and Pods Creation (`deploy_local_k8s.sh`)
The production EKS environment is simulated using local Kubernetes.
1. **Namespaces:** The script creates 5 fully isolated namespaces (e.g., `kong-dp-core`, `kong-dp-credit-cards`).
2. **mTLS Secrets:** It injects the certificates created in step 1 into each namespace using `kubectl create secret tls`.
3. **Helm Deployment:** It uses the official Kong chart (`kong/kong`) to deploy the Data Planes.
   - For the 4 standard business units, it deploys the `kong/kong-gateway:3.15.0.6` image.
   - For the `kong-dp-ai` namespace, it deploys the specialized `kong/kong-ai-gateway:2.0.3` image.
   - It injects environment variables into all of them, connecting them to their respective Konnect Control Plane.
4. **Mockups & Testing:** Auxiliary pods are deployed in the default namespace: an `httpbin` container that acts as a universal backend for all test APIs, and a `test-curl-verify` pod that we later use to inject traffic into the network.

## 5. Network Configuration
- All traffic from the Data Planes to Konnect (CP) is routed outboard through port `443`, encrypted with the DP's own certificate.
- The Data Planes expose their Proxy services (the port where they receive API traffic) through a Kubernetes `LoadBalancer` or NodePort.
- The virtual services (`accounts`, `transactions`) map to the backend at `http://httpbin.default.svc.cluster.local:8080` using Kubernetes' internal DNS resolution (CoreDNS).
