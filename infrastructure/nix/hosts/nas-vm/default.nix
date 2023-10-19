{ config, pkgs, lib, ... }:

{
  imports = [
      # Host-specific hardware
      ./hardware-configuration.nix

      # Common imports
      ../common/nixos
      ../common/nixos/users/bjw-s
      ../common/optional/fish.nix
      ../common/optional/nfs-server.nix
      ../common/optional/qemu.nix
      ../common/optional/samba-server.nix
      ../common/optional/zfs.nix

      # Host-specific imports
      ./zfs.nix
  ];

  networking = {
    hostName = "nas-vm";
    hostId =  "8023d2b9";
    networkmanager.enable = true;
  };

  # may fix issues with network service failing during a nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
