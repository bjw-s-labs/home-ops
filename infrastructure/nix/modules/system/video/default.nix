{ pkgs, lib, config, ... }:
with lib;

let
  cfg = config.modules.system.video;
  device = config.modules.device;
in {
  options.modules.system.video = { enable = mkEnableOption "video"; };

  config = mkIf (cfg.enable) (mkMerge [
    (mkIf (device.gpu == "amd") {
      # enable amdgpu kernel module
      boot.initrd.kernelModules = [ "amdgpu" ];
      services.xserver.videoDrivers = [ "amdgpu" ];
      # enables AMDVLK & OpenCL support
      hardware.opengl.extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      hardware.opengl.extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
      # force use of RADV, can be unset if AMDVLK should be used
      environment.variables.AMD_VULKAN_ICD = "RADV";
    })

    (mkIf (device.gpu == "intel") {
      # enable the i915 kernel module
      boot.initrd.kernelModules = ["i915"];
      # better performance than the actual Intel driver
      services.xserver.videoDrivers = ["modesetting"];
      # OpenCL support and VAAPI
      hardware.opengl.extraPackages = [
        pkgs.intel-compute-runtime
        pkgs.intel-media-driver
        pkgs.vaapiIntel
        pkgs.vaapiVdpau
        pkgs.libvdpau-va-gl
      ];
      environment.variables.VDPAU_DRIVER = "va_gl";
    })
  ]);
}
