{ ... }:

{
  config = {
    modules = {
      device = {
        cpu = "vm";
        gpu = "vm";
        hostId = "0e542f34";
      };

      users.bjw-s.enable = true;

      system.openssh.enable = true;
      system.qemu-guest-agent.enable = true;
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
