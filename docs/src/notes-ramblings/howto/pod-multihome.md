# Run a Pod in a VLAN

Sometimes you'll want to give a Kubernetes Pod direct access to a VLAN.
This could be for any number of reasons, but the most common reason is for the application to be able to automatically discover devices on that VLAN.

A good example of this would be [Home Assistant](https://www.home-assistant.io). This application has several integrations that rely on being able to discover the hardware devices (e.g. [Sonos](https://www.sonos.com) speakers or [ESPHome](https://esphome.io) devices).

<!-- toc -->

## Prerequisites

For a Kubernetes cluster to be able to add additional network interfaces to Pods (this is also known as "multi-homing") the [Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni) needs to be installed in your cluster.

```admonish note
I use the Helm chart provided by [@angelnu](https://github.com/angelnu/helm-charts/tree/main/charts/apps/multus) to install Multus. The reason for using this over the [official deployment method](https://github.com/k8snetworkplumbingwg/multus-cni/blob/master/deployments/multus-daemonset.yml) is that it has better support for upgrade/update scenarios.
```

## NIC configuration

Make sure that the Kubernetes node has a network interface that is connected to the VLAN you wish to connect to.

```admonish note
[My nodes](../../overview/hardware.md) only have a single NIC, so I have [set them up](https://github.com/bjw-s-labs/home-ops/blob/main/infrastructure/talos/main/talconfig.yaml) so their main interface gets it's IP address over DHCP and a virtual interface connecting to the VLAN. How to do this will depend on your operating system.
```

## Multus Configuration

My Multus Helm configuration can be found [here](https://github.com/bjw-s-labs/home-ops/blob/main/kubernetes/main/apps/network/multus/app/helmrelease.yaml).

It is important to note that the paths of your CNI plugin binaries / config might differ depending on the Kubernetes distribution you are running. For my [Talos](https://www.talos.dev) setup they need to be set to `/opt/cni/bin` and `etc/cni/net.d` respectively.

## NetworkAttachmentDefinition

Once the Multus CNI has been installed and configured you can use the `NetworkAttachmentDefinition` Custom Resource to define the virtual IP addresses that you want to hand out. These need to be free addresses within the VLAN subnet, so it's important to make sure that they do not overlap with your DHCP server range(s).

```yaml
{{ #include ../../../../kubernetes/main/apps/home-automation/home-assistant/app/networkattachmentdefinition.yaml }}
```

Be sure to check out the [official documentation](https://github.com/k8snetworkplumbingwg/multus-cni/blob/master/docs/configuration.md) for more information on how to configure the `spec.config` field.

## Pod configuration

Once the NetworkAttachmentDefinition has been loaded it is possible to use it within a Pod. This can be done by setting an annotation on the Pod that references it. Staying with the Home Assistant example ([full Helm values](https://github.com/bjw-s-labs/home-ops/blob/main/kubernetes/main/apps/home-automation/home-assistant/app/helmrelease.yaml)), this would be:

`k8s.v1.cni.cncf.io/networks: macvlan-static-iot-hass`

## App-specific configuration: Home Assistant

In order for Home Assistant to actually use the additional network interface you will need to explicitly enable it instead of relying on automatic network detection.
To do so, navigate to `Settings >> System >> Network` (this setting is only available to Home Assistant users that have "Advanced mode" enabled in their user profile) and place a checkmark next to the adapters that you wish to use with Home Assistant integrations.
