# Kutespace: Argo CD

Spin up a fully configured learning environment for Argo CD in seconds.

## Into
- what is this thing? kutespaces?
- what is argo cd?
- read about all components in section components
- or directly jump into the tasks

## Setup

Start a new Codespace directly from Github. Please start the Codespace in a local VSCode. In-browser execution is not supported yet.

![Start Codespace](docs/images/start-codespace.jpg)


## Components

### Devcontainer / Codespaces

GitHub Codespaces is an online development environment that lets you code inside a remote VM with no setup needed. Devcontainers are a part of this service, providing pre-configured coding environments in containers. With devcontainers, you can set up everything a developer needs, like tools and extensions, so anyone can start coding immediately, ensuring consistency across all team members' workspaces.

### k3d
k3d fully functional kubernetes cluster
k3d ships with traefik loadbalancer by default
traffic from this dev container port 8080 is forwarded to port 80 of the cluster
we configure the traefik load balancer by creating kubernetes ingress resources.
e.g. we configure one ingress argocd.127.0.0.1.nip.io that maps to the argocd kubernetes service.
we use nip.io to get different dns domain names that all map to localhost. However, given different host names the load balancer traefik redirects to different kubernetes services.

### Argo CD

Argo CD automates the deployment and lifecycle management of your applications in Kubernetes by syncing them with configurations stored in a Git repository. When you make changes to your application's configuration and push them to the Git repository, Argo CD detects these changes and applies them to your Kubernetes cluster, ensuring that your live applications always match what's specified in your repository.

This approach has several benefits:

Version Control: Since your configurations are stored in Git, you have a complete history of changes, and you can roll back to previous versions if needed.
Consistency: By using the same configurations from development to production, you avoid discrepancies between environments.
Automation: Manual deployment steps are reduced, which minimizes the risk of human error and saves time.
Self-healing: If something changes in your live environment that doesn't match the repository, Argo CD can automatically correct it.

More Information: https://argo-cd.readthedocs.io/en/stable/

## Tasks

### Checkout ArgoCD Dashboard
- argocd.127.0.0.1.nip.io:8080
- check out the port mappings to see how to access port 8080 of this space with you browser.

![Image](docs/images/portforwarding.jpg)

### Checkout App of Apps Pattern
- checkout app of apps
manifests/app-of-apps.yaml

### Checkout Podinfo Service
- checkout podinfo
    - modify env variable and view that it syncs
    - podinfo.127.0.0.1.nip.io
    - manifests/podinfo

- increase replicas to 2
- check that 2 replicas exist via cli and via kubernetes dashboard

- don't forget to refresh in the argocd ui

### Check out game 2048
- checkout game-2048
    - game-2048.127.0.0.1.nip.io
    - manifests/game-2048


### Deploy own application
deploy this simple kanban board on your own. Check it out in the browser afterwards.
https://docs.kanboard.org/v1/admin/docker/
default user password is admin:admin

don't forget to add the argocd application manifest to the app-of-apps.
this will make the app of apps sync it too

### Present repo structure for real world projects
TODO

## Troubleshooting

You are facing issues? Let us know to help the next person facing the same issue.
