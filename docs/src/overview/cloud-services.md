# :cloud: Cloud services

While most of my infrastructure and workloads are selfhosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

The alternative solution to these two problems would be to host a Kubernetes cluster in the cloud and deploy applications like [HCVault](https://www.vaultproject.io/), [Vaultwarden](https://github.com/dani-garcia/vaultwarden), [ntfy](https://ntfy.sh/), and [Authentik](https://https://goauthentik.io/). However, maintaining another cluster and monitoring another group of workloads is a lot more time and effort than I am willing to put in and only saves me roughly $10/month.

| Service                                      | Use                                                            | Cost          |
| -------------------------------------------- | -------------------------------------------------------------- | ------------- |
| [GitHub](https://github.com/)                | Hosting this repository and continuous integration/deployments | Free          |
| [Auth0](https://auth0.com/)                  | Identity management and authentication                         | Free          |
| [Cloudflare](https://www.cloudflare.com/)    | Domain, DNS and proxy management                               | Free          |
| [1Password](https://1password.com/)          | Secrets with [External Secrets](https://external-secrets.io/)  | ~$65/y        |
| [Terraform Cloud](https://www.terraform.io/) | Storing Terraform state                                        | Free          |
| [B2 Storage](https://www.backblaze.com/b2)   | Offsite application backups                                    | ~$5/m         |
| [Pushover](https://pushover.net/)            | Kubernetes Alerts and application notifications                | Free          |
|                                              |                                                                | Total: ~$10/m |
