username:

{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shell.tmux.${username};

in {
  options.modules.shell.tmux.${username} = {
    enable = mkEnableOption "tmux";

    config = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config.home-manager.users.${username} = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
    };
  };
}
