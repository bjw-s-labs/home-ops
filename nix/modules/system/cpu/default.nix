{ pkgs, lib, config, ... }:

let
  device = config.modules.device;
in {
  config = lib.mkMerge [
    (lib.mkIf (device.cpu == "amd") {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelModules = [ "kvm-amd" ];
    })
    (lib.mkIf (device.cpu == "intel") {
      hardware.cpu.intel.updateMicrocode = true;
      boot.kernelModules = [ "kvm-intel" ];
    })
    (lib.mkIf (device.cpu == "vm") {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelModules = [ "kvm-amd" ];
    })
  ];
}
