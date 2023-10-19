{
  description = "bjw-s Nix Flake";

  inputs = {
    # Nixpkgs and unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # for VSCode remote-ssh
    nix-ld-vscode = {
      url = "github:scottstephens/nix-ld-vscode/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        # "i686-linux"
        # "x86_64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];

      mkNixos = modules: nixpkgs.lib.nixosSystem {
        inherit modules;
        specialArgs = { inherit inputs outputs; };
      };

    in
    {
      nixosModules = import ./modules/nixos;

      nixosConfigurations = {
        # VMs
        "nas-vm" = mkNixos [./hosts/nas-vm];
      };
    };
  # outputs = {
  #   self,
  #   nixpkgs,
  #   ...
  # } @ inputs: let
  #   inherit (self) outputs;
  # in {
  #   nixosConfigurations = {
  #     "nas-vm" = nixpkgs.lib.nixosSystem {
  #       specialArgs = {inherit inputs outputs;};
  #       modules = [
  #         ./nas/configuration.nix
  #         #disko.nixosModules.disko
  #       ];
  #     };
  #   };
}
