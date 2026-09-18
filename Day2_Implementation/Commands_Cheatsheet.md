# 🚀 Cheatsheet: Useful Commands for Kong Bootcamp

This document is a quick reference for the most commonly used commands during the implementation and operation of the Kong Konnect, Kubernetes, and Docker architecture.

---

## ☸️ Kubernetes (`kubectl`)

These commands will help you interact with the Data Planes deployed across the different namespaces.

**View resources:**
- `kubectl get pods -A` : Lists all pods in all namespaces.
- `kubectl get pods -n <namespace>` : Lists pods for a specific namespace (e.g., `kong-dp-credit-cards`).
- `kubectl get svc -n <namespace>` : Lists the services (IPs and ports) of a namespace.
- `kubectl get secret -n <namespace>` : View secrets (like `kong-cluster-cert`).

**Troubleshooting:**
- `kubectl logs -f <pod-name> -n <namespace>` : Shows real-time logs of a pod. Useful to see if the Data Plane connected to Konnect.
- `kubectl describe pod <pod-name> -n <namespace>` : Shows events for a pod. Essential if a pod is stuck in `Pending` or `CrashLoopBackOff` state.
- `kubectl exec -it <pod-name> -n <namespace> -- /bin/sh` : Opens an interactive terminal inside the Kong container.

**Networking:**
- `kubectl port-forward svc/<service-name> 8000:80 -n <namespace>` : Exposes a Kubernetes service on your `localhost:8000`. Useful for testing proxy requests.

---

## 🐳 Docker and Docker Compose

Commands to manage Keycloak and any other external service we run in pure containers.

**Pure Docker:**
- `docker ps` : Lists running containers (you will see Keycloak and Minikube containers).
- `docker logs -f <container-id>` : View logs for a specific container.
- `docker exec -it <container-id> bash` : Enter a container's terminal.

**Docker Compose:** *(Run from the folder where `docker-compose.yml` is located)*
- `docker-compose up -d` : Starts services in the background.
- `docker-compose down` : Destroys containers and associated networks.
- `docker-compose restart` : Restarts services.

---

## 🚢 Minikube

To manage the local Kubernetes cluster where your Data Planes live.

- `minikube start` : Starts the cluster.
- `minikube stop` : Pauses the cluster without deleting data (saves battery/RAM).
- `minikube status` : Checks the status of components.
- `minikube delete` : Completely destroys the cluster (clean slate).
- `minikube dashboard` : Opens a graphical interface in your browser to view everything in Kubernetes.

---

## 🛠️ Operating System and Kong Utils

**Environment Management (Your local script):**
- `source kong-env-switcher.sh` or simply `kong-env` : Opens the menu to load environment variables (`KONG_CP_ENDPOINT`, `KONNECT_TOKEN`, etc.) into your current terminal.
- `env | grep KONG` : Checks which Kong variables are currently loaded in the terminal's memory.

**Kong Tools (decK):** *(Very useful for Day 3 - APIOps)*
- `deck gateway ping` : Verifies that decK can authenticate and talk to Konnect or your Control Plane.
- `deck gateway dump -o kong.yaml` : Exports the entire current configuration of a Control Plane to a YAML file.
- `deck gateway sync kong.yaml` : Synchronizes the state of the YAML file to Konnect (applies the changes).
- `deck gateway diff kong.yaml` : Shows what changes would be applied without actually executing them.
