{ inputs, outputs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./locale.nix
    ./nix.nix
    ./packages.nix
    ./openssh.nix
    ./smartd.nix
    ./systemd-initrd.nix
  ] ++ (builtins.attrValues {});

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  nixpkgs = {
    # Add overlays here
    overlays = [
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];
}
