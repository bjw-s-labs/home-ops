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
  helm repo add jetstack https://charts.jetstack.io
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
    echo "waiting for sealed-secrets pod to be fully ready..."
    kubectl -n "$SS_NAMESPACE" wait --for condition=available deployment/sealed-secrets
    SS_READY="$?"
    sleep 5
  done
}

installCertManager() {
  message "installing cert-manager"
  # install cert-manager
  CERTMANAGER_NAMESPACE="system-cert-manager"
  helm upgrade --install cert-manager --create-namespace --values "$REPO_ROOT"/deployments/"$CERTMANAGER_NAMESPACE"/cert-manager/values.yaml --namespace "$CERTMANAGER_NAMESPACE" jetstack/cert-manager

  CERTMANAGER_READY=1
  while [ $CERTMANAGER_READY != 0 ]; do
    echo "waiting for cert-manager pod to be fully ready..."
    kubectl -n "$CERTMANAGER_NAMESPACE" wait --for condition=available deployment/cert-manager
    CERTMANAGER_READY="$?"
    sleep 5
  done

  CERTMANAGER_WEBHOOK_READY=1
  while [ $CERTMANAGER_WEBHOOK_READY != 0 ]; do
    echo "waiting for cert-manager webhook pod to be fully ready..."
    kubectl -n "$CERTMANAGER_NAMESPACE" wait --for condition=available deployment/cert-manager-webhook
    CERTMANAGER_WEBHOOK_READY="$?"
    sleep 5
  done

  kubectl apply -f "$REPO_ROOT"/deployments/"$CERTMANAGER_NAMESPACE"/cert-manager/issuers/sealedsecret-bjws-lan-ca-keypair.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$CERTMANAGER_NAMESPACE"/cert-manager/issuers/sealedsecret-cloudflare-api-key.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$CERTMANAGER_NAMESPACE"/cert-manager/issuers/issuers.yaml

}

installMetalLb() {
  message "installing metallb"
  # install metallb
  METALLB_NAMESPACE="system-metallb"
  helm upgrade --install metallb --create-namespace --values "$REPO_ROOT"/deployments/"$METALLB_NAMESPACE"/metallb/values.yaml --namespace "$METALLB_NAMESPACE" stable/metallb

  METALLB_READY=1
  while [ $METALLB_READY != 0 ]; do
    echo "waiting for metallb controller pod to be fully ready..."
    kubectl -n "$METALLB_NAMESPACE" wait --for condition=available deployment/metallb-controller
    METALLB_READY="$?"
    sleep 5
  done
}

installFlux
installSealedSecrets
installCertManager
installMetalLb

message "all done!"
kubectl get nodes -o=wide
