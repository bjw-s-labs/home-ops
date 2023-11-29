#!/usr/bin/env bash
# shellcheck disable=2312
pushd integrations >/dev/null 2>&1 || exit 1

rm -rf cni/charts
envsubst < ../apps/kube-system/cilium/app/values.yaml > cni/values.yaml
kustomize build --enable-helm cni | kubectl apply -f -
rm cni/values.yaml
rm -rf cni/charts

rm -rf kubelet-csr-approver/charts
envsubst < ../apps/system-controllers/kubelet-csr-approver/app/values.yaml > kubelet-csr-approver/values.yaml
if ! kubectl get ns system-controllers >/dev/null 2>&1; then
  kubectl create ns system-controllers
fi
kustomize build --enable-helm kubelet-csr-approver | kubectl apply -f -
rm kubelet-csr-approver/values.yaml
rm -rf kubelet-csr-approver/charts
