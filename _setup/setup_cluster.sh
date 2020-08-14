#!/bin/bash
REPO_ROOT=$(git rev-parse --show-toplevel)

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "kubectl"
need "helm"

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

addHelmRepos() {
  helm repo add stable https://kubernetes-charts.storage.googleapis.com
  helm repo add fluxcd https://charts.fluxcd.io
}

installFlux() {
  message "installing flux"
  # install flux
  FLUX_NAMESPACE="system-flux"
  helm upgrade --install flux --create-namespace --values "$REPO_ROOT"/deployments/"$FLUX_NAMESPACE"/flux/values.yaml --namespace "$FLUX_NAMESPACE" fluxcd/flux
  helm upgrade --install helm-operator --values "$REPO_ROOT"/deployments/"$FLUX_NAMESPACE"/helm-operator/values.yaml --namespace "$FLUX_NAMESPACE" fluxcd/helm-operator

  FLUX_READY=1
  while [ $FLUX_READY != 0 ]; do
    echo "waiting for flux pod to be fully ready..."
    kubectl -n "$FLUX_NAMESPACE" wait --for condition=available deployment/flux
    FLUX_READY="$?"
    sleep 5
  done

  # grab output the key
  FLUX_KEY=$(kubectl -n "$FLUX_NAMESPACE" logs deployment/flux | grep identity.pub | cut -d '"' -f2)

  message "adding the key to github automatically"
  "$REPO_ROOT"/_setup/scripts/add-repo-key.sh "$FLUX_KEY"
}

installSealedSecrets() {
  message "installing sealed-secrets"
  # install sealed-secrets
  SS_NAMESPACE="system"
  kubectl apply -f "$REPO_ROOT"/_secrets/master.key
  helm upgrade --install sealed-secrets --create-namespace --values "$REPO_ROOT"/deployments/"$SS_NAMESPACE"/sealed-secrets/values.yaml --namespace "$SS_NAMESPACE" stable/sealed-secrets

  SS_READY=1
  while [ $SS_READY != 0 ]; do
    echo "waiting for flux pod to be fully ready..."
    kubectl -n "$SS_NAMESPACE" wait --for condition=available deployment/sealed-secrets
    SS_READY="$?"
    sleep 5
  done
}

installFlux
installSealedSecrets

message "all done!"
kubectl get nodes -o=wide