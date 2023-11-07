{ config, ... }:

{
  modules = {
    device = {
      cpu = "intel";
      gpu = "intel";
      hostId = "775b7d55";
    };

    users = {
      presetUsers = [
        "bjw-s"
        "manyie"
      ];

      groups = {
        external-services = {
          gid = 65542;
        };
        admins = {
          gid = 991;
          members = ["bjw-s"];
        };
      };
    };

    filesystem.zfs.enable = true;
    filesystem.zfs.mountPoolsAtBoot = [
      "tank"
    ];

    monitoring.smartd.enable = true;

    servers.k3s.enable = true;
    servers.nfs.enable = true;
    servers.samba.enable = true;
    servers.samba.shares = {
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

    shell.openssh.enable = true;
    system.video.enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
