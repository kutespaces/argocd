# Kutespace: Argo CD

Welcome to Kutespace's Argo CD repository! This guide will help you spin up a fully preconfigured learning environment with Kubernetes & Argo CD.

## Learning Outcomes

As you embark on these exercises, you're set to learn key practices in modern application deployment and management. Here's what you'll achieve by the end of this guide:

- **Implementing GitOps Workflow**: You'll use Git as the source of truth for your infrastructure, applying changes that automatically trigger deployments.
- **Using Argo CD Dashboard**: You'll learn to navigate the Argo CD dashboard, monitoring the status and health of your applications.
- **Deploying Your Own Application**: Before diving into more advanced concepts, you'll start by using provided templates to deploy an application of your choice, integrating it with the GitOps workflow.
- **Rolling Back Changes**: You'll exercise version control to revert deployments, appreciating the benefits of a Git-driven workflow.
- **Understanding Multi-Stage Deployments**: You'll explore how to manage multiple deployment environments using Argo CD, enhancing your understanding of real-world DevOps practices.

By the end of these exercises, you'll have a solid foundation in deploying and managing Kubernetes applications using Argo CD.

## Getting Started

To begin, launch a new Codespace directly from GitHub. Ensure you start the Codespace in a local VSCode instance, as in-browser execution is not currently supported.

<img src='docs/images/start-codespace.jpg' width='50%'>

## Exercises

### Exercise 1: Verify the Kubernetes Setup

Start by ensuring you can interact with Kubernetes:

1. Request the nodes; you should see a single node returned:

```shell
kubectl get nodes
```

2. Check the pods across all namespaces. Look for services like Argo CD, a local git server, and a Traefik load balancer:

```shell
kubectl get pods --all-namespaces
```

Ensure the pod statuses are 'Completed' or 'Running'.

### Exercise 2: Access the Argo CD Dashboard

Access the Argo CD dashboard through your browser. The URL format is `http://argocd.127.0.0.1.nip.io:<FORWARDED K3D INGRESS PORT>`. The load balancer listens on port 8080, which is forwarded to your local machine. Locate your local machine's corresponding port in the `PORTS` tab of VS Code.

<img src='docs/images/portforwarding.jpg' width='100%'>

Login with the credentials `admin:admin` to view the dashboard. You should see the following 3 Argo CD applications.

<img src='docs/images/argocdapps.jpg' width='100%'>

If you encounter syncing issues, refresh the 'app-of-apps' app within the dashboard.

### Exercise 3: Explore Podinfo Service

Explore the Podinfo service by visiting `podinfo.127.0.0.1.nip.io:<FORWARDED K3D INGRESS PORT>`. Follow these steps to modify the Podinfo UI color and observe the GitOps workflow in action:

1. Change the `PODINFO_UI_COLOR` in `manifests/podinfo/resources/deployment.yaml`.
2. Commit and push your changes.
3. Use `watch kubectl get pods -n podinfo` to watch the rolling update.
4. Refresh the Podinfo app in the Argo CD dashboard to trigger a sync.

<img src='docs/images/podinfogold.png' width='50%'>

### Exercise 4: Rollback Changes

To revert changes, use Git to revert the commit and push the changes. Refresh the Podinfo app in the Argo CD dashboard and observe the UI color return to jade green.

### Exercise 5: GitOps End-to-End Workflow

Understand the GitOps workflow by inspecting the `./manifests` folder, the Argo CD setup in `./manifests/argocd`, and the 'app-of-apps' pattern in `./manifests/argocd-apps`. Take time to understand the file structure and the role of each component.

### Exercise 6: Play Game 2048

Take a break and enjoy the game 2048, deployed using the same GitOps principles. Visit `http://game-2048.127.0.0.1.nip.io:<FORWARDED K3D INGRESS PORT>`.

<img src='docs/images/2048.png' width='33%'>

### Exercise 7: Deploy Your Own Application

Now it's time to deploy an application of your choice. Use the manifests for Podinfo (`./manifests/podinfo`) and Game 2048 (`./manifests/game-2048`) as a starting point to create your own.

1. Select an application to deploy, such as [Kanboard](https://docs.kanboard.org/v1/admin/docker/), and prepare its Docker deployment configuration.

2. Copy the structure of the `podinfo` or `game-2048` manifest directories and update the Kubernetes manifests for your application.

3. Create a new Argo CD application manifest in `./manifests/argocd-apps`, modeled after the existing examples.

4. Instead of applying your application manifest directly, add it to the `./manifests/app-of-apps.yaml` to let Argo CD manage the deployment as part of its automated process.

5. Commit and push your changes to the repository, then watch Argo CD automatically deploy your application through the 'app-of-apps' approach.

Remember, your application will be accessible via `http://<your-app-name>.127.0.0.1.nip.io:<FORWARDED K3D INGRESS PORT>`. Use the default credentials `admin:admin` if deploying Kanboard.


### Exercise 8: Real-World Multi-Stage Deployment

This exercise demonstrates a practical approach to deploying applications for different environments using Argo CD. We'll deploy two variants of the Podinfo application, one for a staging environment and another for production, each with different configurations.

#### Understanding the Folder Structure

The folder `./manifests/multi-stage-example` is structured as follows:

```
├── app-of-apps.yaml
├── argocd-apps
│   ├── kustomization.yaml
│   ├── podinfo-staging.yaml
│   └── podinfo-production.yaml
└── podinfo
    ├── base
    ├── production
    └── staging
```

- `app-of-apps.yaml`: This is the root application that Argo CD uses to deploy other applications in a cascading fashion.
- `argocd-apps`: Contains individual Argo CD application manifests for different environments (staging and production).
- `podinfo`: Houses the shared base manifests and overlays for specific environments.

#### Deploying Staging and Production Variants

The `podinfo-staging.yaml` and `podinfo-production.yaml` files define the Argo CD applications for staging and production. These applications are configured to apply environment-specific patches, such as different hostnames or UI colors, to the base `podinfo` manifests.

Follow these steps to deploy both environments:

1. Apply the 'app-of-apps' manifest:

```shell
kubectl apply -f ./manifests/multi-stage-example/app-of-apps.yaml
```

2. This will create the staging and production Argo CD applications, which will then deploy the Podinfo app for each environment:

- Staging: `http://podinfo-staging.127.0.0.1.nip.io:<FORWARDED K3D INGRESS PORT>`
- Production: `http://podinfo-production.127.0.0.1.nip.io:<FORWARDED K3D INGRESS PORT>`

3. Verify that the applications are deployed correctly in Argo CD and accessible via their respective URLs.

#### Customizing the Deployment

To alter the application for different environments, you can modify the `kustomization.yaml` and corresponding patches within the `staging` and `production` folders. For instance, the production variant changes the UI color to aqua blue:

- Inspect the `production/deployment-patch.yaml` to see the environment variable patch.
- Review the `production/kustomization.yaml` to understand how Kustomize applies the patch.

By using this folder structure and Kustomize overlays, you can manage multiple environments efficiently, reusing base manifests while allowing for environment-specific customizations.

### Congratulations!

Congratulations on completing the exercises! You've successfully navigated through a series of tasks that have introduced you to the power of Argo CD and the principles of GitOps within a Kubernetes environment.

## Troubleshooting

Encountering issues? Let us know to assist you and others who may face similar challenges.

### DNS Resolution
If `argocd.127.0.0.1.nip.io` cannot be resolved, switch your DNS to a public DNS provider like Google (8.8.8.8) or Cloudflare (1.1.1.1). Apparently, some DNS servers don't resolve DNS entries that point to localhost.
