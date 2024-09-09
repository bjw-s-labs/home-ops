# Run a Service with both TCP and UDP

One example where it is really nice having a single unified Service expose all the ports instead of several "single-purpose" ones is the Unifi Controller: [Helm values](https://github.com/bjw-s-labs/home-ops/blob/main/kubernetes/main/apps/network/unifi/app/helmrelease.yaml).

Up until Kubernetes version 1.26 it was (by default) not possible to have a single Service expose **both** TCP _and_ UDP protocols.

## Prerequisites

Since Kubernetes version 1.26 the `MixedProtocolLBService` has graduated to GA status, and no special flags should be required.
Up until version 1.26 it was required to enable the `MixedProtocolLBService=true` [feature-gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/) in order to achieve this functionality.
