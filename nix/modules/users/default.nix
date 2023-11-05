{ lib, config, ... }:

let
  cfg = config.modules.users;
in {
  imports = [
    ./bjw-s
    ./manyie
  ];

  options.modules.users = {
    presetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };
}
