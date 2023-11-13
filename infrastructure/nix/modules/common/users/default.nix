{ lib, config, ... }:
with lib;

let
  cfg = config.modules.users;
in {
  options.modules.users = {
    groups = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = {
    users.groups = cfg.groups;
  };
}
