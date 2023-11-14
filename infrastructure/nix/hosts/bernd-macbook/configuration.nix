{ ... }:

{
  config = {
    modules = {
      users.bjw-s = {
        enable = true;
        enableKubernetesTools = true;
      };
    };

    # # Use the systemd-boot EFI boot loader.
    # boot.loader.systemd-boot.enable = true;
    # boot.loader.efi.canTouchEfiVariables = true;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog

  };
}
