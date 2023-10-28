{ pkgs, lib, config, ... }:
{
  programs.atuin = {
    enable = true;
    package = pkgs.unstable.atuin;

    flags = [
      "--disable-up-arrow"
    ];

    settings = {
      sync_address = "https://atuin.bjw-s.dev";
      auto_sync = true;
      sync_frequency = "1m";
      search_mode = "fuzzy";
    };
  };
}
