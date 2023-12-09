#!/usr/bin/env bash
set -euo pipefail
[[ -n "${TRACE:-}" ]] && set -x
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

main() {
  echo "on-create begin"
  echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create begin" >> "$HOME/status"

  # Delete k3d cluster if it exists to remove all associated resources
  if k3d cluster list | grep -q k3s-default; then
    echo "deleting existing k3d cluster"
    k3d cluster delete k3s-default
  fi

  # Check if the k3d registry exists
  if k3d registry list | grep -qw k3d-registry.localhost; then
      echo "Registry k3d-registry.localhost exists. Deleting it..."
      k3d registry delete k3d-registry.localhost
  fi

  # Delete existing k3d network
  if docker network ls | grep -q k3d; then
    echo "deleting existing k3d network"
    docker network rm k3d
  fi

  echo "creating k3d network"
  docker network create k3d

  # Create the k3d registry
  k3d registry create registry.localhost --port 5500

  # Create k3d cluster and connect everything to the new network
  echo "creating k3d cluster"
  k3d cluster create -c .devcontainer/k3d.yaml

  # Activate kubectl autocompletion for zsh. Not everybody wants to use k9s.
  echo 'source <(kubectl completion zsh)' >>~/.zshrc
  echo 'alias k=kubectl' >>~/.zshrc

  # Deploy k8s resources
  kubectl apply -k manifests/argocd
  # set argocd dasboard admin pw to admin
  kubectl patch secret -n argocd argocd-secret -p '{"stringData": {"admin.password": "$2y$10$49UjmQBCYm406qFoLdyzhO72DKJ9JM7m3uAO70vvapSseAPf2ZTcy"}}'
  kubectl apply -k manifests/git-repo-server
  # deploy app of apps which deploys all other apps

    

  ELAPSED_TIME=0
  # Wait for the CRD to be installed with a timeout
  until kubectl get crd applications.argoproj.io &> /dev/null || [ $ELAPSED_TIME -ge 60 ]; do
    echo "Waiting for Argo CD Application CRD to be installed..."
    sleep 10
    ELAPSED_TIME=$((ELAPSED_TIME+10))
  done
  kubectl apply -f manifests/app-of-apps.yaml

  echo "on-create end"
  echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create end" >> "$HOME/status"
}

main "$@"
