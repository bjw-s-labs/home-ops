{ pkgs, ... }:
{
  programs.lsd.enable = true;
  programs.zoxide.enable = true;
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
      # lsd
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -a";
      lt = "lsd --tree";
      lla = "lsd -la";

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
