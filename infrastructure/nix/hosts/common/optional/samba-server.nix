{
  users.groups.samba-users = {};

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      guest account = nobody
      map to guest = bad user
      veto files = /._*/.DS_Store/
      delete veto files = yes
      inherit acls = yes
      map acl inherit = yes
      valid users = @samba-users
    '';
  };
}
