# Networking

My current cluster-internal networking is implemented by [calico][calico]{target=_blank}.

## Running high-available control-plane

In order to expose my control-plane on a loadbalanced IP address, I have deployed [kube-vip][kube-vip]{target=_blank}.
It is configured to expose a load balanced address to the host IP addresses of my control-plane nodes over BGP.

## Exposing services on their own IP address

Most (http/https) traffic enters my cluster through an Ingress controller. For situations where this is not desirable (e.g. MQTT traffic) or when I need a fixed IP reachable from outside the cluster (e.g. to use in combination with port forwarding) I use [metallb][metallb]{target=_blank} in [layer2 mode](https://metallb.universe.tf/concepts/layer2/){target=_blank}.

Using this setup I can define a Service to use a `loadBalancerIP`, and it will be exposed on my network on that given IP address.

### Mixed-protocol services

I have enabled the `MixedProtocolLBService=true` feature-gate on my cluster. This means that I can combine UDP and TCP ports on the same Service.

### BGP

Due to the way that BGP works, a node can only set up a single BGP connection to the router. Since I am already running [kube-vip][kube-vip]{target=_blank} in BGP mode and I have a limited number of nodes, I am currently not using BGP mode to expose my services.

!!! note
    Currently when using BGP on Opnsense, services do not get properly load balanced. This is due to Opnsense not supporting multipath in the BSD kernel

{% include 'links.md' %}
