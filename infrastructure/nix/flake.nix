{
  description = "bjw-s Nix Flake";

  inputs = {
    # Nixpkgs and unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs = { flake-parts, ... }@inputs:
    let
      myLib = import ./lib/default.nix { inherit inputs; };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      perSystem = {
        inputs',
        pkgs,
        ...
      }: {
        # legacyPackages = import ./nixos/packages { inherit inputs' pkgs; };
        # devShells.default = import ./nixos/packages/shell.nix { inherit inputs' pkgs; };
      };

      flake.nixosConfigurations = {
        nas = myLib.mkNixosSystem     "x86_64-linux"  "gladius";
        test-vm = myLib.mkNixosSystem "aarch64-linux" "test-vm";
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#<hostname>
      flake.darwinConfigurations = {
        personal-macbook = myLib.mkDarwinSystem "aarch64-darwin" "bernd-macbook";
      };
    };
}
