{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
    };
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
}
