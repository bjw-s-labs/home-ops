{ inputs, ... }: let
  inherit (inputs.nixpkgs) lib;
in {
  mkNixosSystem = system: hostname:
    lib.nixosSystem {
      inherit system;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import ../packages/overlay.nix {inherit inputs system;})
        ];
      };
      modules = [
        {
          _module.args = {
            inherit inputs system;
            myConfig = { hostname = hostname; };
            # nvfetcherPath = ../packages/_sources/generated.nix;
            # myPkgs = inputs.self.legacyPackages.${system};
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
              overlays = [ (import ../packages/overlay.nix {inherit inputs system;}) ];
            };
          };
        }
        inputs.home-manager.nixosModules.home-manager
        # Load the modules
        ../modules/common
        ../modules/nixos
        # Host specific configuration
        ../hosts/${hostname}/configuration.nix
        # Host specific hardware configuration
        ../hosts/${hostname}/hardware-configuration.nix
      ];
    };

  mkDarwinSystem = system: hostname:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import ../packages/overlay.nix {inherit inputs system;})
        ];
      };
      modules = [
        {
          _module.args = {
            inherit inputs system;
            myConfig = { hostname = hostname; };
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
              overlays = [ (import ../packages/overlay.nix {inherit inputs system;}) ];
            };
          };
        }
        inputs.home-manager.darwinModules.home-manager
        # Load the modules
        ../modules/common
        ../modules/darwin
        # Host specific configuration
        ../hosts/${hostname}/configuration.nix
      ];
      specialArgs = { inherit inputs; };
    };
}
