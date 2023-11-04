{ pkgs, config, lib, myConfig, ... }:
with lib;
{
  options.modules.device = {
    cpu = mkOption {
      type = types.enum ["amd" "intel" "vm"];
    };
    gpu = mkOption {
      type = types.enum ["amd" "intel" "nvidia" "vm"];
    };

    hostname = mkOption {
      type = types.str;
      default = myConfig.hostname;
    };
  };
}
