{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasExa = hasPackage "exa";
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
      ls = mkIf hasExa "exa";
      ll = mkIf hasExa "exa -laag --git --icons --sort=type";
      llrt = mkIf hasExa "exa -laag --git --icons -snew";
      l = mkIf hasExa "exa -l --git --icons --sort=type";

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
