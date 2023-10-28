{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasLsd = hasPackage "lsd";
in
{
  programs.fish = {
    enable = true;

    plugins = [
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "puffer"; src = pkgs.fishPlugins.puffer.src; }
      {
        name = "zoxide";
        src = pkgs.fetchFromGitHub {
          owner = "kidonng";
          repo = "zoxide.fish";
          rev = "bfd5947bcc7cd01beb23c6a40ca9807c174bba0e";
          sha256 = "Hq9UXB99kmbWKUVFDeJL790P8ek+xZR5LDvS+Qih+N4=";
        };
      }
    ];

    shellAliases = {
      # exa
      ls = mkIf hasLsd "lsd";
      ll = mkIf hasLsd "lsd -l";
      la = mkIf hasLsd "lsd -a";
      lt = mkIf hasLsd "lsd --tree";
      lla = mkIf hasLsd "lsd -la";

      # other
      df = "df -h";
      du = "du -h";
    };

    functions = {
      # Disable greeting
      fish_greeting = "";
    };
  };
}
