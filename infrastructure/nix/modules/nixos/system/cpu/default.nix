{ pkgs, lib, config, ... }:
with lib;

let
  device = config.modules.device;
in {
  config = mkMerge [
    (mkIf (device.cpu == "amd") {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelModules = [ "kvm-amd" ];
    })
    (mkIf (device.cpu == "intel") {
      hardware.cpu.intel.updateMicrocode = true;
      boot.kernelModules = [ "kvm-intel" ];
    })
    (mkIf (device.cpu == "vm") {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelModules = [ "kvm-amd" ];
    })
  ];
}
