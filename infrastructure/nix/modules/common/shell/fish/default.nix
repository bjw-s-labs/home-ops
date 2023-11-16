{ username }: {lib, config, ... }:
with lib;
let
  cfg = config.modules.users.${username}.shell.fish;

  defaultConfig = import ./defaultConfig.nix;
in {
   options.modules.users.${username}.shell.fish = {
    enable = mkEnableOption "${username} fish";

    config = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf (cfg.enable) {
    programs.fish.enable = true;

    programs.fish.loginShellInit =
      let
        # This naive quoting is good enough in this case. There shouldn't be any
        # double quotes in the input string, and it needs to be double quoted in case
        # it contains a space (which is unlikely!)
        dquote = str: "\"" + str + "\"";

        makeBinPathList = map (path: path + "/bin");
      in ''
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
        set fish_user_paths $fish_user_paths
      '';

    home-manager.users.${username} = mkIf (cfg.enable) (mkMerge [
      defaultConfig
      cfg.config
    ]);
  };
}
