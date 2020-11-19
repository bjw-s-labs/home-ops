# My home Kubernetes cluster managed by GitOps

![Kubernetes](https://i.imgur.com/p1RzXjQ.png)

[![Discord](https://img.shields.io/badge/discord-chat-7289DA.svg?maxAge=60&style=flat-square)](https://discord.gg/d7C9M7)    [![k3s](https://img.shields.io/badge/k3s-v1.18.8-orange?style=flat-square)](https://k3s.io/)    [![GitHub stars](https://img.shields.io/github/stars/bjw-s/k8s-gitops?color=green&style=flat-square)](https://github.com/bjw-s/k8s-gitops/stargazers)    [![GitHub issues](https://img.shields.io/github/issues/bjw-s/k8s-gitops?style=flat-square)](https://github.com/bjw-s/k8s-gitops/issues)    [![GitHub last commit](https://img.shields.io/github/last-commit/bjw-s/k8s-gitops?color=purple&style=flat-square)](https://github.com/bjw-s/k8s-gitops/commits/main) [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

---

## Overview

Welcome to my home Kubernetes cluster.

Lots of fun (to me at least ;)) stuff can be found, poke around my [deployments](./deployments/) directory to see what my cluster is running. Feel free to open a [GitHub Issue](https://github.com/bjw-s/k8s-gitops/issues/new).

[Renovatebot](https://github.com/renovatebot/renovate) keeps my applications up-to-date by scanning my repo and opening pull requests when it notices a new container image update.

[Actions Runner Controller](https://github.com/summerwind/actions-runner-controller) operates a self-hosted Github runner in my cluster which I use to generate Sealed Secrets to my cluster.

---

## Hardware

This cluster runs on the following hardware (all nodes are running bare-metal on Ubuntu 20.04):

| Device                                  | Count | OS Disk Size | Data Disk Size       | Ram  | Purpose                                          |
|-----------------------------------------|-------|--------------|----------------------|------|--------------------------------------------------|
| Lenovo ThinkCentre M93p Tiny (i5-4570T) | 1     | 250GB SSD    | N/A                  | 8GB  | k3s Master                                       |
| Intel NUC8i5BEH                         | 1     | 512GB NVMe   | 1TB SSD (longhorn)   | 32GB | k3s Worker                                       |
| Intel NUC8i5BEH                         | 1     | 480GB SS D   | 1TB NVMe             | 32GB | k3s Worker                                       |
| Intel NUC8i3BEH                         | 1     | 512GB NVMe   | 1TB SSD (longhorn)   | 32GB | k3s Worker                                       |
| Synology NAS (librarium)                | 1     | N/A          | 3x6TB SHR, 512GB SSD | 8GB  | Media and general (S3-compatible) storage bucket |

---
## Community

We've got a vibrant community of folks all running various Kubernetes workloads at home. Click the Discord link above to join us!

---
## Thanks

A lot of inspiration for this repo came from the following people:
- [onedr0p/k3s-gitops](https://github.com/onedr0p/k3s-gitops)
- [billimek/k8s-gitops](https://github.com/billimek/k8s-gitops)
- [carpenike/k8s-gitops](https://github.com/carpenike/k8s-gitops)
- [dcplaya/k8s-gitops](https://github.com/dcplaya/k8s-gitops)
