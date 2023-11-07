{ lib, config, ... }:

let
  cfg = config.modules.users;
in {
  options.modules.users = {
    presetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    groups = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config = {
    users.mutableUsers = false;
    users.groups = cfg.groups;
  };
}
