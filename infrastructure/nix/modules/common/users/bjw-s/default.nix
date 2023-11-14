args@{ pkgs, pkgs-unstable, lib, config, ... }:
with lib;

let
  cfg = config.modules.users.bjw-s;
in {
  imports = [
    ( import ../../home-manager { username="bjw-s"; } )
  ];

  options.modules.users.bjw-s = {
    enable = mkEnableOption "bjw-s";
  };

  config = mkIf (cfg.enable) (mkMerge [
    (mkIf (pkgs.stdenv.isLinux) (import ./nixos.nix args))
    (mkIf (pkgs.stdenv.isDarwin) (import ./darwin.nix args))

    {
      users.users.bjw-s = {
        shell = pkgs.fish;
      };

      modules.users.bjw-s.home-manager.enable = true;

      modules.users.bjw-s.sops = {
        defaultSopsFile = ./secrets.sops.yaml;
        secrets = {
          atuin_key = {
            path = "${config.home-manager.users.bjw-s.xdg.configHome}/atuin/key";
          };
        };
      };

      modules.users.bjw-s.shell.atuin = {
        enable = true;
        package = pkgs-unstable.atuin;
        sync_address = "https://atuin.bjw-s.dev";
        config = {
          key_path = config.home-manager.users.bjw-s.sops.secrets.atuin_key.path;
        };
      };

      modules.users.bjw-s.shell.fish.enable = true;

      modules.users.bjw-s.shell.git = {
        enable = true;
        username = "Bernd Schorgers";
        email = "me@bjw-s.dev";
        signing = {
          signByDefault = true;
          key = "0x80FF2B2CE4316DEE";
        };
        aliases = {
          co = "checkout";
          logo = "log --pretty=format:\"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ (%cn)\" --decorate";
        };
        config = {
          core = {
            autocrlf = "input";
          };
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = false;
          };
        };
        ignores = [
          # Mac OS X hidden files
          ".DS_Store"
          # Windows files
          "Thumbs.db"
          # asdf
          ".tool-versions"
          # rtx
          ".rtx.toml"
          # Sops
          ".decrypted~*"
          # Python virtualenvs
          ".venv"
        ];
      };

      modules.users.bjw-s.shell.rtx = {
        enable = true;
        package = pkgs-unstable.rtx;
      };

      modules.users.bjw-s.shell.starship.enable = true;
      modules.users.bjw-s.shell.tmux.enable = true;
    }
  ]);
}
