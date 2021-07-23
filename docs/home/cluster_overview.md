# Cluster overview

My cluster is [k3s][k3s]{target=_blank} provisioned on Ubuntu 21.04 nodes using the [Ansible](https://www.ansible.com/){target=_blank} galaxy role [ansible-role-k3s](https://github.com/PyratLabs/ansible-role-k3s){target=_blank}. This is a semi hyper-converged cluster, workloads and block storage are sharing the same available resources on my nodes.

See my [ansible](https://github.com/bjw-s/k8s-gitops/tree/main/ansible){target=_blank} directory for my playbooks and roles.

## Hardware

| Device                         | Count | OS Disk Size | Data Disk Size       | Ram  | Purpose                     |
|--------------------------------|-------|--------------|----------------------|------|-----------------------------|
| Intel NUC8i3BEH                | 1     | 512GB SSD    | 1TB NVMe (rook-ceph) | 32GB | k3s Masters (embedded etcd) |
| Intel NUC8i5BEH                | 2     | 512GB SSD    | 1TB NVMe (rook-ceph) | 32GB | k3s Masters (embedded etcd) |
| Lenovo ThinkCentre M93p Tiny   | 1     | 256GB SSD    | N/A                  |  8GB | k3s Workers                 |
| Synology DS918+                | 1     | N/A          | 3x6TB + 1x10TB SHR   | 16GB | Shared file storage         |

## Kubernetes cluster components

### GitOps

- [flux][flux]{target=_blank}: Keeps the cluster in sync with this Git repository.
- [Mozilla SOPS](https://toolkit.fluxcd.io/guides/mozilla-sops/){target=_blank}: Encrypts secrets which is safe to store - even to a public repository.

### Networking

See [here](../../networking) for more information about my storage setup.

- [calico][calico]{target=_blank}: For internal cluster networking.
- [kube-vip][kube-vip]{target=_blank}: Uses BGP to load balance the control-plane API, making it highly availible without requiring external HA proxy solutions.
- [metallb][metallb]{target=_blank}: Uses layer 2 to provide Load Balancing features to my cluster.
- [external-dns][external-dns]{target=_blank}: Creates DNS entries in a separate [coredns](https://github.com/coredns/coredns){target=_blank} deployment which lives on my router.
- [Multus](https://github.com/k8snetworkplumbingwg/multus-cni){target=_blank}: For allowing pods to have multiple network interfaces.
- [cert-manager](https://cert-manager.io/docs/){target=_blank}: Configured to create TLS certs for all ingress services automatically using [LetsEncrypt](https://letsencrypt.org){target=_blank}.

### Storage

See [here](../../storage) for more information about my storage setup.

- [rook-ceph](https://rook.io/){target=_blank}: Provides persistent volumes, allowing any application to consume RBD block storage or CephFS storage.
- [Kasten k10](https://www.kasten.io){target=_blank}: Data backup and recovery

{% include 'links.md' %}
