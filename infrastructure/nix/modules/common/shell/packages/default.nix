{pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.jq
    pkgs.yq
  ];
}
