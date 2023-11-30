{ username }: {lib, config, ... }:
with lib;
let
  cfg = config.modules.users.${username}.shell.tmux;

in {
  options.modules.users.${username}.shell.tmux = {
    enable = mkEnableOption "${username} tmux";

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
