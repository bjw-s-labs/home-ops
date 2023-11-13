{ lib, config, ... }:
with lib;

let
  cfg = config.modules.system.qemu-guest-agent;
in {
  options.modules.system.qemu-guest-agent = {
    enable = mkEnableOption "qemu-guest-agent";
  };

  config = mkIf cfg.enable {
    services.qemuGuest.enable = true;
  };
}
