{ lib, config, ... }:

let
  cfg = config.modules.users;
in {
  options.modules.users = {
    presetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = {
    users.mutableUsers = false;
  };
}
