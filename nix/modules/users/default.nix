{ lib, config, ... }:
with lib;
let
  cfg = config.modules.users;
in {
  imports = [
    ./bjw-s
    ./manyie
  ];

  options.modules.users = {
    presetUsers = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };
}
