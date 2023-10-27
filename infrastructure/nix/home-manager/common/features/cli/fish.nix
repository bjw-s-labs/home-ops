{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasExa = hasPackage "exa";
in
{
  programs.fish = {
    enable = true;
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
