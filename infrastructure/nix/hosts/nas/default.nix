{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
      # Host-specific hardware
      ./hardware-configuration.nix

      # Common imports
      ../common/nixos
      ../common/nixos/users/bjw-s
      ../common/optional/fish.nix
      ../common/optional/k3s-server.nix
      ../common/optional/nfs-server.nix
      ../common/optional/qemu.nix
      ../common/optional/samba-server.nix
      # ../common/optional/starship.nix
      ../common/optional/zfs.nix
  ];

  networking = {
    hostName = "gladius";
    hostId = "775b7d55";
    networkmanager.enable = true;
  };

  # User config
  users.users = {
    manyie = {
      isNormalUser = true;
      extraGroups = [
        "samba-users"
      ];
    };
  };

  # Group config
  users.groups = {
    external-services = {
      gid = 65542;
    };
    admins = {
      members = ["bjw-s"];
    };
  };

  # Packages
  environment.systemPackages = [
    pkgs.rclone
  ];

  # ZFS config
  boot.zfs = {
    extraPools = [
      "tank"
    ];
  };

  # Samba config
  services.samba.shares = {
    Docs = {
      path = "/tank/Docs";
      "read only" = "no";
    };
    Media = {
      path = "/tank/Media";
      "read only" = "no";
    };
    Paperless = {
      path = "/tank/Apps/paperless/incoming";
      "read only" = "no";
    };
    Software = {
      path = "/tank/Software";
      "read only" = "no";
    };
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
