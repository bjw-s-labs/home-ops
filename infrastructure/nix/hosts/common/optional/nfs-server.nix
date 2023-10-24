{
  services.nfs.server.enable = true;
  networking.firewall.allowedTCPPorts = [ 2049 ];
}
