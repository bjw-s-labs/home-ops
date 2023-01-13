## Exposing services on their own IP address

Most (http/https) traffic enters my cluster through an Ingress controller. For situations where this is not desirable (e.g. MQTT traffic) or when I need a fixed IP reachable from outside the cluster (e.g. to use in combination with port forwarding) I use {{ links.external('metallb') }} in [layer2 mode](https://metallb.universe.tf/concepts/layer2/){target=_blank}.

Using this setup I can define a Service to use a `loadBalancerIP`, and it will be exposed on my network on that given IP address.
