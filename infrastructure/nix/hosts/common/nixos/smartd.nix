{ config, pkgs, lib, ... }:
{
  services.smartd.enable = true;
  environment.systemPackages = [ pkgs.smartmontools ];
}
