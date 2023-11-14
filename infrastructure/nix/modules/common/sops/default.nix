{ username }: {lib, pkgs, config, inputs, ... }:
with lib;
let
  cfg = config.modules.users.${username}.sops;
in {
  options.modules.users.${username}.sops = {
    defaultSopsFile = mkOption {
      type = types.path;
    };
    secrets = mkOption {
      type = types.attrs;
      default = {};
    };
    ageKeyFile = mkOption {
      type = types.str;
      default = "${config.home-manager.users.${username}.xdg.configHome}/age/keys.txt";
    };
  };

  config = {
    home-manager.users.${username} = {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      home.packages = [
        pkgs.sops
        pkgs.age
      ];

      sops = {
        defaultSopsFile = cfg.defaultSopsFile;
        age.sshKeyPaths = [
          cfg.ageKeyFile
        ];
        secrets = cfg.secrets;
      };

      home.sessionVariables = optionalAttrs (pkgs.stdenvNoCC.isDarwin) {
        SOPS_AGE_KEY_FILE = cfg.ageKeyFile;
      };
    };
  };
}
