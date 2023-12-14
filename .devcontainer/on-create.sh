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

  mkdir -p output
  cat ~/.kube/config > output/kubeconfig.yaml

  # Activate kubectl autocompletion for zsh. Not everybody wants to use k9s.
  echo 'source <(kubectl completion zsh)' >>~/.zshrc
  echo 'alias k=kubectl' >>~/.zshrc

  # install local git server and configure git client to use it
  kubectl apply -k manifests/git-repo-server

  GIT_REMOTE_URL="http://git.127.0.0.1.nip.io:8080/git/manifests"

  # Change to the repository directory
  pushd "./manifests" > /dev/null

  # Initialize the repository if it's not already initialized and add the remote
  if [ ! -d ".git" ]; then
      git init
      git remote add origin "$GIT_REMOTE_URL"
  fi

  git add -A
  git diff --staged --quiet || git commit -m "Initial commit"

  # Wait for the Git server to be ready with a timeout
  ELAPSED_TIME=0
  until curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 $GIT_REMOTE_URL/info/refs?service=git-receive-pack | grep -q "200" || [ $ELAPSED_TIME -ge 90 ]; do
    echo "Waiting for Git server to be ready..."
    sleep 5
    ELAPSED_TIME=$((ELAPSED_TIME+5))
  done
  git push -u origin main
  # Change back to the original directory
  popd > /dev/null


  kubectl apply -k manifests/argocd

  # Wait for the argocd application CRD to be installed
  ELAPSED_TIME=0
  until kubectl get crd applications.argoproj.io &> /dev/null || [ $ELAPSED_TIME -ge 90 ]; do
    echo "Waiting for Argo CD Application CRD to be installed..."
    sleep 5
    ELAPSED_TIME=$((ELAPSED_TIME+5))
  done
  echo "Waiting for argocd repo server to be ready"
  kubectl wait --namespace argocd --for=condition=Ready pod -l app.kubernetes.io/component=repo-server,app.kubernetes.io/instance=argocd --timeout=60s
  echo "Argocd repo server is ready"
  kubectl apply -f manifests/app-of-apps/argocd-app.yaml

  echo "on-create end"
  echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create end" >> "$HOME/status"
}

main "$@"
