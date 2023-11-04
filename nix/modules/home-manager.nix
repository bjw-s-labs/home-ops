{ config, lib, options, ... }:
with lib;
{
  options = {
    home = {
      manager = mkOption {
        type = types.attrs;
        default = {};
      };
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
