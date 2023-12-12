#!/usr/bin/env bash
set -euxo pipefail
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

  cat ~/.kube/config > output/kubeconfig.yaml

  # Activate kubectl autocompletion for zsh. Not everybody wants to use k9s.
  echo 'source <(kubectl completion zsh)' >>~/.zshrc
  echo 'alias k=kubectl' >>~/.zshrc

  # install local git server and configure git client to use it
  kubectl apply -k manifests/git-repo-server
  # Check if the 'origin' remote is set to the local git server
  EXPECTED_URL="http://git.127.0.0.1.nip.io:8080/git/argocd"
  CURRENT_URL=$(git remote get-url origin 2>/dev/null)
  if [ "$CURRENT_URL" != "$EXPECTED_URL" ]; then
    git remote rename origin github
    git remote add origin http://git.127.0.0.1.nip.io:8080/git/argocd
  fi


  # Wait for the Git server to be ready with a timeout
  ELAPSED_TIME=0
  SERVER_URL="http://git.127.0.0.1.nip.io:8080/git/argocd/info/refs?service=git-receive-pack"
  until curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 $SERVER_URL | grep -q "200" || [ $ELAPSED_TIME -ge 90 ]; do
    echo "Waiting for Git server to be ready..."
    sleep 5
    ELAPSED_TIME=$((ELAPSED_TIME+5))
  done
  git push -u origin main

  kubectl apply -k manifests/argocd
  # deploy app of apps which deploys all other apps
  # replace with kubectl wait --for=condition=established crd/your-crd-name --timeout=60s
  # Wait for the argocd application CRD to be installed with a timeout
  ELAPSED_TIME=0
  until kubectl get crd applications.argoproj.io &> /dev/null || [ $ELAPSED_TIME -ge 90 ]; do
    echo "Waiting for Argo CD Application CRD to be installed..."
    sleep 5
    ELAPSED_TIME=$((ELAPSED_TIME+5))
  done
  kubectl apply -f manifests/app-of-apps.yaml

  echo "on-create end"
  echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create end" >> "$HOME/status"
}

main "$@"
