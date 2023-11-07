{ config, lib, pkgs, inputs, ... }:
let
  deviceCfg = config.modules.device;
in {

  networking.hostName = deviceCfg.hostname;

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
  };

  time.timeZone = "Europe/Amsterdam";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # Delete older generations too
      options = "--delete-older-than 2d";
    };
  };

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

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
