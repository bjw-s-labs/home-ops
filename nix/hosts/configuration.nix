{ config, pkgs, inputs, ... }:
let
  deviceCfg = config.modules.device;
in {

  networking.hostName = deviceCfg.hostname;

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

  home.manager = {
    home = {
      stateVersion = "23.05";
    };

    programs = {
      home-manager.enable = true;
    };
  };
}
