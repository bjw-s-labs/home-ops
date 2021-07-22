# k8s-gitops

Welcome to the documentation for [bjw-s/k8s-gitops](https://github.com/bjw-s/k8s-gitops).

This repository _is_ my home Kubernetes cluster in a declarative state. [Flux](https://github.com/fluxcd/flux2) watches my [cluster](https://github.com/bjw-s/k8s-gitops/cluster/) folder and makes the changes to my cluster based on the YAML manifests.

Feel free to open a [Github issue](https://github.com/bjw-s/k8s-gitops/issues/new/choose) or join the [k8s@home Discord](https://discord.gg/sTMX7Vh) if you have any questions.

## Cluster setup

My cluster is [k3s](https://k3s.io/) provisioned on Ubuntu 21.04 nodes using the [Ansible](https://www.ansible.com/) galaxy role [ansible-role-k3s](https://github.com/PyratLabs/ansible-role-k3s). This is a semi hyper-converged cluster, workloads and block storage are sharing the same available resources on my nodes.

See my [ansible](https://github.com/bjw-s/k8s-gitops/ansible/) directory for my playbooks and roles.

## Cluster components

### GitOps

- [flux](https://fluxcd.io): Keeps the cluster in sync with this Git repository.
- [Mozilla SOPS](https://toolkit.fluxcd.io/guides/mozilla-sops/): Encrypts secrets which is safe to store - even to a public repository.

### Networking

- [calico](https://docs.projectcalico.org/about/about-calico): For internal cluster networking.
- [kube-vip](https://kube-vip.io/): Uses BGP to load balance the control-plane API, making it highly availible without requiring external HA proxy solutions.
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Creates DNS entries in a separate [coredns](https://github.com/coredns/coredns) deployment which lives on my router.
- [Multus](https://github.com/k8snetworkplumbingwg/multus-cni): For allowing pods to have multiple network interfaces.
- [cert-manager](https://cert-manager.io/docs/): Configured to create TLS certs for all ingress services automatically using [LetsEncrypt](https://letsencrypt.org).

### Storage

- [rook-ceph](https://rook.io/): Provides persistent volumes, allowing any application to consume RBD block storage or CephFS storage.
- [Kasten k10](https://www.kasten.io): Data backup and recovery

## Repository structure

The Git repository contains the following directories under `cluster` and are ordered below by how Flux will apply them.

```
./cluster
├── ./apps
├── ./base
├── ./core
└── ./crds
```

- **`base`** directory is the entrypoint to Flux
- **`crds`** directory contains custom resource definitions (CRDs) that need to exist globally in my cluster before anything else exists
- **`core`** directory (depends on **crds**) are important infrastructure applications that should never be pruned by Flux
- **`apps`** directory (depends on **core**) is where my common applications (grouped by namespace) are placed. Flux will prune resources here if they are not tracked by Git anymore.

## Automate all the things!

- [Github Actions](https://docs.github.com/en/actions) for checking code formatting
- Rancher [System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) to apply updates to k3s
- [Renovate](https://github.com/renovatebot/renovate) with the help of the [k8s-at-home/renovate-helm-releases](https://github.com/k8s-at-home/renovate-helm-releases) Github action keeps my application charts and container images up-to-date

## Hardware

| Device                         | Count | OS Disk Size | Data Disk Size       | Ram  | Purpose                     |
|--------------------------------|-------|--------------|----------------------|------|-----------------------------|
| Intel NUC8i3BEH                | 1     | 512GB SSD    | 1TB NVMe (rook-ceph) | 32GB | k3s Masters (embedded etcd) |
| Intel NUC8i5BEH                | 2     | 512GB SSD    | 1TB NVMe (rook-ceph) | 32GB | k3s Masters (embedded etcd) |
| Lenovo ThinkCentre M93p Tiny   | 1     | 256GB SSD    | N/A                  |  8GB | k3s Workers                 |
| Synology DS918+                | 1     | N/A          | 3x6TB + 1x10TB SHR   | 16GB | Shared file storage         |

## Tools

| Tool                                                   | Purpose                                                      |
|--------------------------------------------------------|--------------------------------------------------------------|
| [direnv](https://github.com/direnv/direnv)             | Sets environment variables and tool environments based on present working directory |
| [pre-commit](https://github.com/pre-commit/pre-commit) | Enforce code consistency and verifies no secrets are pushed  |
| [stern](https://github.com/stern/stern)                | Tail logs in Kubernetes                                      |

## Thanks

A lot of inspiration for my cluster came from the people that have shared their clusters over at [awesome-home-kubernetes](https://github.com/k8s-at-home/awesome-home-kubernetes)
