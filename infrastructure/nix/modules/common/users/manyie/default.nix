{ pkgs, lib, config, ... }:
with lib;

let
  cfg = config.modules.users.manyie;
in {
  options.modules.users.manyie = {
    enable = mkEnableOption "manyie";
  };

  config = mkIf (cfg.enable) (mkMerge [
    (mkIf (pkgs.stdenv.isLinux) (import ./nixos.nix {inherit config;}))
    (mkIf (pkgs.stdenv.isDarwin) (import ./darwin.nix {inherit config;}))
  ]);
}
