# Notes

Problem: this is already a git repository but we may need another remote to push it to a local server thats connected to argocd. Maybe change remote during devcontainer creation.

Problem: it's a little weird that the user just has to commit but not to push.

Check out this repo: https://github.com/rockstorm101/gitweb-docker. Maybe we can just use this lightweight container to visualize all repositories in `workspaces`. It also allows unauthenticated access to http to pull the repos.

Upsides:
- user doesn't need to push at all
Downsides:
- we need to adjust pull frequency of argocd

Alternative:

- use other git server with ui.



Message an Felix:

Next steps bevor man es rausschicken kann:

- finde die ux weird mit commiten aber nicht pushen. Würde das gerne 1:1 haben wie bei in echt. Passt dir das?
- muss noch k9s installieren (gab errors mit dem feature)
- ggf. schauen dass man sowas wie lens connecten kann.
- würde gerne noch ein real-world setup mit mehreren stages präsentieren. Da kannst du mir nochmal die Struktur von charles mit kustomize schicken bzw. deinen aktuellen Favorite.
- geile Readme schreiben mit so ner Art Missionen / Guidance aber halt einfach als Markdown runterschreiben.
- ggf. DNS von devcontainer und pods verbinden dann kann man direkt auf alles zugreifen

Fehlt da noch was?

Dannach kann man

1. es ggf. schon rausballern mit LinkedIn Posts und schauen obs Leuten gefällt.
2. wenns Leuten gefällt bei ArgoCD nachhaken was man tun müsste damit die es publishen.
3. anderen Repos schicken und fragen ob die sowas für sich haben möchten.



# NEW GITHUB README

## Into
- what is this thing? kutespaces?
- what is argo cd?
- read about all components in section components
- or directly jump into the tasks

## Components

### k3d
k3d fully functional kubernetes cluster
k3d ships with traefik loadbalancer by default
traffic from this dev container port 8080 is forwarded to port 80 of the cluster
we configure the traefik load balancer by creating kubernetes ingress resources.
e.g. we configure one ingress argocd.127.0.0.1.nip.io that maps to the argocd kubernetes service.
we use nip.io to get different dns domain names that all map to localhost. However, given different host names the load balancer traefik redirects to different kubernetes services.

### Argo CD


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
- modify env variable and view it
- podinfo.127.0.0.1.nip.io
manifests/podinfo

### Check out game 2048
- checkout game-2048
- game-2048.127.0.0.1.nip.io
- manifests/game-2048

### Deploy own application
- deploy own app in new folder

### Present repo structure for real world projects
- repo structure for real world projects
