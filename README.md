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

### Create flux-system

kubectl create ns flux-system  


### Create sops-age secret
cat ~/.config/sops/age/keys.txt |
    kubectl -n flux-system create secret generic sops-age \
    --from-file=age.agekey=/dev/stdin


### Bootstrap flux & install cluster
flux install --version=v0.27.0 --export | kubectl apply -f -
kubectl apply -k k8s/clusters/sidero/