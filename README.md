<!-- markdownlint-disable MD041 -->
<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="left" width="144px" height="144px"/>

# My home Kubernetes cluster managed by GitOps

_... managed by Flux and serviced with RenovateBot_ :robot:

<br/>
<br/>
<br/>

<div align="center">

[![Discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label=discord&logo=discord&logoColor=white&color=teal)](https://discord.gg/sTMX7Vh)
[![k3s](https://img.shields.io/badge/k3s-v1.21.3-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled?logo=pre-commit&logoColor=white&style=for-the-badge&color=brightgreen)](https://github.com/pre-commit/pre-commit)
[![renovate](https://img.shields.io/badge/renovate-enabled?style=for-the-badge&logo=renovatebot&logoColor=white&color=brightgreen)](https://github.com/renovatebot/renovate)

</div>

---

## :wave: Overview

Welcome to my home operations repository.

Lots of fun (to me at least :wink:) stuff can be found, poke around my [Kubernetes clusters](./k8s/clusters/) directory to see what they are running. Feel free to open a [GitHub Issue](https://github.com/dcplaya/home-ops/issues/new).

For more information, head on over to my [docs](https://dcplaya.github.io/home-ops/).

---

## :handshake:&nbsp; Thanks

A lot of inspiration for my cluster came from the people that have shared their clusters over at [awesome-home-kubernetes](https://github.com/k8s-at-home/awesome-home-kubernetes)


## Installation Notes

Below are the steps to bootstrap the sidero cluster
Similar steps may be the same for other cluster stuff but havent gotten to that yet.

### Generate Sidero Talos config
Since this is a single node cluster, untainting the control plane allows for Sidero to run
Also add feature gates for kubelet
```
talosctl gen config \
  --config-patch='[{"op": "add", "path": "/cluster/allowSchedulingOnMasters", "value": true},{"op": "add", "path": "/machine/kubelet/extraArgs", "value": { "feature-gates": "GracefulNodeShutdown=true,MixedProtocolLBService=true" } }]' \
  sidero \
  https://$SIDERO_ENDPOINT:6443/
```

### Boot Talos ISO and apply the config
```
talosctl apply-config --insecure \
  --nodes $SIDERO_ENDPOINT \
  --file ./controlplane.yaml
```

### Set talosctl endpoints and nodes and merge into default talosconfig
```
# To pull the talosconfig from the sidero cluster
kubectl --context=admin@sidero \
    get secret \
    cluster-1-talosconfig \
    -o jsonpath='{.data.talosconfig}' \
  | base64 -d \
   > cluster-1-talosconfig


talosctl --talosconfig=./talosconfig \
    config endpoint $SIDERO_ENDPOINT

talosctl --talosconfig=./talosconfig \
   config node $SIDERO_ENDPOINT

talosctl config merge ./talosconfig
```

Verify the default talosconfig can connect to the Talos node. It should show both the client and server (ndoe) version
```
talosctl version
```


### Bootstrap k8s
This may take 2-5 minutes so be patient
```
talosctl bootstrap --nodes $SIDERO_ENDPOINT
```

### Grab kubeconfig from the node and merge it with default kubeconfig

```
talosctl kubeconfig
```

### Bootstrap Sidero
```
# This boostraps a entire sidero setup on your testing cluster.
# HOST_NETWORK is critical to make it work else it doesnt have access to the ports it needs
SIDERO_CONTROLLER_MANAGER_HOST_NETWORK=true \
SIDERO_CONTROLLER_MANAGER_API_ENDPOINT=$SIDERO_ENDPOINT \
clusterctl init -b talos -c talos -i sidero
```

## Install Flux
These steps will be repeated for each cluster that is created.
Flux does not get auto-deployed on the Sidero created clusters
### Create flux-system

```
kubectl create ns flux-system
```


### Create sops-age secret
```
cat ~/.config/sops/age/keys.txt |
    kubectl -n flux-system create secret generic sops-age \
    --from-file=age.agekey=/dev/stdin
```


### Bootstrap flux & install cluster
Make sure the target folder is changed for the cluster you want to deploy
For my repo, it is the folder that contains `deploy-cluster.yaml`
```
CLUSTER_TARGET_FOLDER=k8s/clusters/sidero/

flux install --version=v0.27.3 --export | kubectl apply -f -
kubectl apply -k $CLUSTER_TARGET_FOLDER
```

# Reset Node
```
NODE=cp1.cluster-1
talosctl reset  --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --reboot --nodes $NODE 
```


# Add 2 drives to my ZFS NAS
https://docs.oracle.com/cd/E53394_01/html/E54801/gayrd.html#scrolltoc

`-n` is for dry run
```
zpool status
zpool add Media mirror $DEV_DEVICE1 $DEV_DEVICE2 -n

sudo reboot
sudo zpool import Media
sudo reboot
```

# Upgrade Talos OS
## Sidero Cluster
```
talosctl upgrade --nodes sidero.FQDN.com --context sidero \
--image ghcr.io/siderolabs/installer:v1.0.3 \
--preserve=true
```
## Workload Cluster
```
talosctl upgrade --nodes cp1.cluster-1.FQDN.com --context clsuter-1 \
--image ghcr.io/siderolabs/installer:v1.0.3
```