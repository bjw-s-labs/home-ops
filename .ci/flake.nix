{
  description = "CI Nix Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    # System-specific logic
    flake-utils.lib.eachDefaultSystem
      (system:    # Non-system-specific logic
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = {
          default = pkgs.mkShell
            {
              buildInputs = (with pkgs; [
                fluxcd
                jo
              ]);
            };
        };
      });
}
