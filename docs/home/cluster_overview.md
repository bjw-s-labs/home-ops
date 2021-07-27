# Cluster overview

{% import 'links.jinja2' as links %}

My cluster is {{ links.external('k3s') }} provisioned on Ubuntu 21.04 nodes using the {{ links.external('ansible') }} galaxy role {{ links.external('ansible-role-k3s') }}. This is a semi hyper-converged cluster, workloads and block storage are sharing the same available resources on my nodes.

See my {{ links.repoUrl('ansible', 'tree/main/ansible') }} directory for my playbooks and roles.

## Hardware

| Device                         | Count | OS Disk Size | Data Disk Size       | Ram  | Purpose                     |
|--------------------------------|-------|--------------|----------------------|------|-----------------------------|
| Intel NUC8i3BEH                | 1     | 512GB SSD    | 1TB NVMe (rook-ceph) | 32GB | k3s Masters (embedded etcd) |
| Intel NUC8i5BEH                | 2     | 512GB SSD    | 1TB NVMe (rook-ceph) | 32GB | k3s Masters (embedded etcd) |
| Lenovo ThinkCentre M93p Tiny   | 1     | 256GB SSD    | N/A                  |  8GB | k3s Workers                 |
| Synology DS918+                | 1     | N/A          | 3x6TB + 1x10TB SHR   | 16GB | Shared file storage         |

## Kubernetes cluster components

### GitOps

- {{ links.external('flux') }}: Keeps the cluster in sync with this Git repository.
- {{ links.external('sops') }}: Encrypts secrets which is safe to store - even to a public repository.

### Networking

See [here](../../networking) for more information about my storage setup.

- {{ links.external('calico') }}: For internal cluster networking.
- {{ links.external('kube-vip') }}: Uses BGP to load balance the control-plane API, making it highly availible without requiring external HA proxy solutions.
- {{ links.external('metallb') }}: Uses layer 2 to provide Load Balancing features to my cluster.
- {{ links.external('external-dns') }}: Creates DNS entries in a separate {{ links.external('coredns') }} deployment which lives on my router.
- {{ links.external('multus') }}: For allowing pods to have multiple network interfaces.
- {{ links.external('cert-manager') }}: Configured to create TLS certs for all ingress services automatically using {{ links.external('letsencrypt') }}.

### Storage

See [here](../../storage) for more information about my storage setup.

- {{ links.external('rook-ceph') }}: Provides persistent volumes, allowing any application to consume RBD block storage or CephFS storage.
- {{ links.external('kasten') }}: Data backup and recovery
