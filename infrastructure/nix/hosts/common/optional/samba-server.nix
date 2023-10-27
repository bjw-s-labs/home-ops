{
  users.groups.samba-users = {};

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      min protocol = SMB2
      workgroup = WORKGROUP

      browseable = yes
      guest ok = no
      guest account = nobody
      map to guest = bad user
      inherit acls = yes
      map acl inherit = yes
      valid users = @samba-users

      veto files = /._*/.DS_Store/
      delete veto files = yes
    '';
  };
}
