# Hardware

| Device                           | Count | OS Disk Size | Data Disk Size                 | Ram  | Operating System                | Purpose              |
|--------------------------------- |-------|--------------|--------------------------------|------|---------------------------------|----------------------|
| YCSD 6LAN i211 MiniPC i3 7100U   | 1     | 128GB mSATA  | -                              | 8GB  | [VyOS](http://vyos.net)         | Router               |
| Intel NUC8i3BEH                  | 1     | 512GB SSD    | 1TB NVMe (rook-ceph)           | 32GB | [Talos](https://www.talos.dev)  | Kubernetes Node      |
| Intel NUC8i5BEH                  | 2     | 512GB SSD    | 1TB NVMe (rook-ceph)           | 32GB | [Talos](https://www.talos.dev)  | Kubernetes Node      |
| Synology DS918+                  | 1     | -            | 2x14TB + 1x10TB + 1x6TB (SHR)  | 8GB  | Synology DSM7                   | NFS + Backup Server  |
| Raspberry Pi 4                   | 1     | 128GB (SD)   | -                              | 4GB  | [PiKVM](https://pikvm.org)      | Network KVM          |
| Unifi USW-Lite-16-PoE            | 2     | -            | -                              | -    | -                               | Core network switch  |
| Unifi USW-Flex-Mini              | 1     | -            | -                              | -    | -                               | Secondary network switch  |
| Unifi UAP-AC-Pro                 | 4     | -            | -                              | -    | -                               | Wireless AP          |
