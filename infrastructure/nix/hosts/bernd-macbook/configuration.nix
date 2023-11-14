{ ... }:

{
  modules = {
    users.bjw-s = {
      enable = true;
      enableKubernetesTools = true;
    };
  #   device = {
  #     cpu = "intel";
  #     gpu = "intel";
  #     hostId = "775b7d55";
  #   };

  #   users = {
  #     presetUsers = [
  #       "bjw-s"
  #       "manyie"
  #     ];

  #     groups = {
  #       external-services = {
  #         gid = 65542;
  #       };
  #       admins = {
  #         gid = 991;
  #         members = ["bjw-s"];
  #       };
  #     };
  #   };

  #   filesystem.zfs.enable = true;
  #   filesystem.zfs.mountPoolsAtBoot = [
  #     "tank"
  #   ];

  #   monitoring.smartd.enable = true;

  #   servers.k3s.enable = true;
  #   servers.nfs.enable = true;
  #   servers.samba.enable = true;
  #   servers.samba.shares = {
  #     Docs = {
  #       path = "/tank/Docs";
  #       "read only" = "no";
  #     };
  #     Media = {
  #       path = "/tank/Media";
  #       "read only" = "no";
  #     };
  #     Paperless = {
  #       path = "/tank/Apps/paperless/incoming";
  #       "read only" = "no";
  #     };
  #     Software = {
  #       path = "/tank/Software";
  #       "read only" = "no";
  #     };
  #   };

  #   shell.openssh.enable = true;
  #   system.video.enable = true;
  };

  # # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
