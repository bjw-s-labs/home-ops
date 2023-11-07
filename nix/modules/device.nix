{ pkgs, config, lib, myConfig, ... }:

{
  options.modules.device = {
    cpu = lib.mkOption {
      type = lib.types.enum ["amd" "intel" "vm"];
    };
    gpu = lib.mkOption {
      type = lib.types.enum ["amd" "intel" "nvidia" "vm"];
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = myConfig.hostname;
    };

    presetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };
}
