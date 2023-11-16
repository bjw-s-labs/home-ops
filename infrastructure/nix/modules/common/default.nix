{ config, pkgs,... }:
let
  deviceCfg = config.modules.device;
in
{
  imports = [
    ./device.nix

    ./users
    ./users/bjw-s
    ./users/manyie
  ];

  networking.hostName = deviceCfg.hostname;

  time.timeZone = "Europe/Amsterdam";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      # Delete older generations too
      options = "--delete-older-than 2d";
    };
  };

  environment.systemPackages = with pkgs; [
    gnused
    gnugrep
  ];
}
