# Tools

| Tool                                                   | Purpose                                                      |
|--------------------------------------------------------|--------------------------------------------------------------|
| [direnv](https://github.com/direnv/direnv)             | Sets environment variables and tool environments based on present working directory |
| [pre-commit](https://github.com/pre-commit/pre-commit) | Enforce code consistency and verifies no secrets are pushed  |
| [stern](https://github.com/stern/stern)                | Tail logs in Kubernetes                                      |

## Automate all the things!

- [Github Actions](https://docs.github.com/en/actions) for checking code formatting
- Rancher [System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) to apply updates to k3s
- [Renovate](https://github.com/renovatebot/renovate) with the help of the [k8s-at-home/renovate-helm-releases](https://github.com/k8s-at-home/renovate-helm-releases) Github action keeps my application charts and container images up-to-date
