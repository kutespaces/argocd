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
  source ~/.zshrc

  # Deploy k8s resources
  kubectl apply -k .devcontainer/manifests/argocd
  kubectl apply -k .devcontainer/manifests/git-repo-server

  echo "on-create end"
  echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create end" >> "$HOME/status"
}

main "$@"
