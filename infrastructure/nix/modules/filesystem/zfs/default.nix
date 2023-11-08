{ lib, config, ... }:
with lib;

let
  cfg = config.modules.filesystem.zfs;
in {
  options.modules.filesystem.zfs = {
    enable = mkEnableOption "zfs";
    mountPoolsAtBoot = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs = {
        forceImportRoot = false;
        extraPools = cfg.mountPoolsAtBoot;
      };
    };

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };
}
