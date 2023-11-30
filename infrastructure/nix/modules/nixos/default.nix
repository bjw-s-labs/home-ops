{ config, lib, ... }:
with lib;

let
  deviceCfg = config.modules.device;
in
{
  imports = [
    ./filesystem/zfs

    ./monitoring/smartd

    ./servers/nfs
    ./servers/k3s
    ./servers/samba

    ./system/cpu
    ./system/openssh
    ./system/qemu-guest-agent
    ./system/video

    ./users
  ];

  boot.initrd.systemd.enable = true;

  networking.hostId = deviceCfg.hostId;

  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
  };

  nix.gc.dates = "weekly";

  documentation.nixos.enable = false;

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  system.stateVersion = "23.11";
}
