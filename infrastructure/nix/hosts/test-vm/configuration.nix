{ config, ... }:

{
  modules = {
    device = {
      cpu = "vm";
      gpu = "vm";
      hostId = "0e542f34";
    };

    users = {
      presetUsers = [
        "bjw-s"
      ];
    };

    shell.openssh.enable = true;

    system.qemu-guest-agent.enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
