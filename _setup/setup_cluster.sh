#!/bin/bash
REPO_ROOT=$(git rev-parse --show-toplevel)

need() {
    command -v "$1" &>/dev/null || (echo "Binary '$1' is missing but required" && exit 1)
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

installSealedSecrets() {
  message "installing sealed-secrets"
  SS_NAMESPACE="system"
  kubectl apply -f "$REPO_ROOT"/deployments/"$SS_NAMESPACE"/namespace.yaml
  kubectl apply -f "$REPO_ROOT"/.secrets/master.key
  helm upgrade --install sealed-secrets --create-namespace --values "$REPO_ROOT"/deployments/"$SS_NAMESPACE"/sealed-secrets/values.yaml --namespace "$SS_NAMESPACE" stable/sealed-secrets

  SS_READY=1
  while [ $SS_READY != 0 ]; do
    echo "waiting for sealed-secrets pod to be fully ready..."
    kubectl -n "$SS_NAMESPACE" wait --for condition=available deployment/sealed-secrets
    SS_READY="$?"
    sleep 5
  done
}

installFlux() {
  message "installing flux"
  FLUX_NAMESPACE="system-flux"
  kubectl apply -f "$REPO_ROOT"/deployments/"$FLUX_NAMESPACE"/namespace.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$FLUX_NAMESPACE"/flux/sealedsecret-flux-git-deploy.yaml

  helm upgrade --install flux --create-namespace --values "$REPO_ROOT"/deployments/"$FLUX_NAMESPACE"/flux/values.yaml --namespace "$FLUX_NAMESPACE" fluxcd/flux
  FLUX_READY=1
  while [ $FLUX_READY != 0 ]; do
    echo "waiting for flux pod to be fully ready..."
    kubectl -n "$FLUX_NAMESPACE" wait --for condition=available deployment/flux
    FLUX_READY="$?"
    sleep 5
  done

  helm upgrade --install --create-namespace helm-operator --values "$REPO_ROOT"/deployments/"$FLUX_NAMESPACE"/helm-operator/values.yaml --namespace "$FLUX_NAMESPACE" fluxcd/helm-operator
  HELMOPERATOR_READY=1
  while [ $HELMOPERATOR_READY != 0 ]; do
    echo "waiting for helm-operator pod to be fully ready..."
    kubectl -n "$FLUX_NAMESPACE" wait --for condition=available deployment/helm-operator
    HELMOPERATOR_READY="$?"
    sleep 5
  done
}

installCertManager() {
  message "installing cert-manager"
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

  kubectl apply -f "$REPO_ROOT"/deployments/"$CERTMANAGER_NAMESPACE"/cert-manager/issuers/sealedsecret-bjws-lan-ca-key-pair.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$CERTMANAGER_NAMESPACE"/cert-manager/issuers/sealedsecret-cloudflare-api-key-secret.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$CERTMANAGER_NAMESPACE"/cert-manager/issuers/issuers.yaml
}

installMetalLb() {
  message "installing metallb"
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

installIngress() {
  message "installing ingress-nginx"
  INGRESS_NAMESPACE="system-ingress"
  kubectl apply -f "$REPO_ROOT"/deployments/"$INGRESS_NAMESPACE"/namespace.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$INGRESS_NAMESPACE"/ingress-nginx/helmrelease.yaml

  sleep 5

  INGRESS_READY=1
  while [ $INGRESS_READY != 0 ]; do
    echo "waiting for ingress-nginx controller pod to be fully ready..."
    kubectl -n "$INGRESS_NAMESPACE" wait --for condition=available deployment/ingress-nginx-controller
    INGRESS_READY="$?"
    sleep 5
  done
}

installLonghorn() {
  message "installing longhorn"
  LONGHORN_NAMESPACE="longhorn-system"
  kubectl apply -f "$REPO_ROOT"/deployments/"$LONGHORN_NAMESPACE"/namespace.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$LONGHORN_NAMESPACE"/longhorn/sealedsecret-longhorn-helm-values.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$LONGHORN_NAMESPACE"/longhorn/sealedsecret-longhorn-backup-secret.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$LONGHORN_NAMESPACE"/longhorn/helmrelease.yaml

  sleep 5

  LONGHORN_READY=1
  while [ $LONGHORN_READY != 0 ]; do
    echo "waiting for longhorn controller pod to be fully ready..."
    kubectl -n "$LONGHORN_NAMESPACE" wait --for condition=available deployment/longhorn-driver-deployer
    LONGHORN_READY="$?"
    sleep 5
  done

  kubectl apply -f "$REPO_ROOT"/deployments/"$LONGHORN_NAMESPACE"/longhorn/storageclass-singlereplica.yaml
}

installOpa() {
  message "installing open policy agent"
  OPA_NAMESPACE="system-opa"
  kubectl apply -f "$REPO_ROOT"/deployments/"$OPA_NAMESPACE"/namespace.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$OPA_NAMESPACE"/opa/configmap-opa-default.yaml
  kubectl apply -f "$REPO_ROOT"/deployments/"$OPA_NAMESPACE"/opa/helmrelease.yaml
  sleep 5

  OPA_READY=1
  while [ $OPA_READY != 0 ]; do
    echo "waiting for opa pod to be fully ready..."
    kubectl -n "$OPA_NAMESPACE" wait --for condition=available deployment/opa
    OPA_READY="$?"
    sleep 5
  done
}

# exit when any command fails
set -e

installSealedSecrets
installFlux
installCertManager
installMetalLb
installIngress
installLonghorn
installOpa

message "all done!"
kubectl get nodes -o=wide
