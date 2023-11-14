{
  nix.gc.interval = {
    Weekday = 0;
    Hour = 2;
    Minute = 0;
  };

  services.nix-daemon.enable = true;

  # Use touch ID for sudo auth
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 4;
}
