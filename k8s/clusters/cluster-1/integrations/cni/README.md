Run this from this folder when the nodes are waiting to be "Ready"

```
kubectl kustomize . --enable-helm | kubectl apply -f -
```





This info may not be useful. Keeping it just in case

# Installing CNI Cilium
```
export KUBERNETES_API_SERVER_ADDRESS=cluster-1.elcarpenter.com
export KUBERNETES_API_SERVER_PORT=6443

helm install cilium cilium/cilium \
    --version 1.12.1 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=strict \
    --set autoDirectNodeRoutes=true \
    --set bgp.announce.loadbalancerIP=true \
    --set bgp.enabled=false \
    --set containerRuntime.integration=containerd \
    --set endpointRoutes.enabled=true \
    --set hubble.enabled=false \
    --set ipv4NativeRoutingCIDR=10.40.0.0/16 \
    --set k8sServiceHost=cluster-1.elcarpenter.com \
    --set k8sServicePort=6443 \
    --set loadBalancer.algorithm=malgev \
    --set loadBalancer.mode=dsr \
    --set localRedirectPolicy=true \
    --set operator.rollOutPods=true \
    --set rollOutCiliumPods=true \
    --set securityContext.privileged=true \
    --set tunnel=disabled \
    --set k8sServiceHost="${KUBERNETES_API_SERVER_ADDRESS}" \
    --set k8sServicePort="${KUBERNETES_API_SERVER_PORT}"
```