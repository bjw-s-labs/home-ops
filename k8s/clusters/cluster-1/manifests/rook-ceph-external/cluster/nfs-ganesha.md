# NFS-Ganesha Client Setup

## Create Ceph client keyrings
Create these on the PVE servers and import them

 I used https://pve.proxmox.com/wiki/User:Grin/Ceph_Object_Gateway to get the commands. Modifying them as needed

nfs-ganesha client permissions
```
caps mds = "allow rw"
caps mon = "allow r"
caps osd = "allow rw"
```

---
## Create Ubuntu 20.04 LTS Container
(Nothing newer is supported)

```
systemctl enable ssh
systemctl start ssh

adduser $USER
usermod -aG sudo $USER
```
```
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:nfs-ganesha/nfs-ganesha-4
sudo add-apt-repository ppa:nfs-ganesha/libntirpc-4
sudo apt update
sudo apt-get install nfs-ganesha nfs-ganesha-ceph nfs-ganesha-rados-grace nfs-ganesha-rados-urls nfs-ganesha-rgw ceph-common

sudo systemctl enable nfs-ganesha
sudo systemctl start nfs-ganesha
```

## Setup Ceph Client
---
## Setup NFS-Ganesha

The setup uses Rados to keep track of the NFS connections (`rados_kv`) as well as watching a `rados_url` for changes to the config and will reload NFS-Ganesha. The `ganesha.conf` will link the `rados_url` to grab the new changes.

1. Fill out the `rados_url` config file that is stored in Ceph. Store this at `/etc/ganesha/ceph.conf`

Important things to set
`Filesystem = ceph_backups ` The name of the cephfs pool. Omit the `_data` addition of the pool if a `_metadata` pool exists for it
`RecoveryBackend = rados_cluster` The type of recovery backend uses. This is the newest type that is beta-ish
`Pseudo = /Media/` The name of the NFS export

```
#
# It is possible to use FSAL_CEPH to provide an NFS gateway to CephFS. The
# following sample config should be useful as a starting point for
# configuration. This basic configuration is suitable for a standalone NFS
# server, or an active/passive configuration managed by some sort of clustering
# software (e.g. pacemaker, docker, etc.).
#
# Note too that it is also possible to put a config file in RADOS, and give
# ganesha a rados URL from which to fetch it. For instance, if the config
# file is stored in a RADOS pool called "nfs-ganesha", in a namespace called
# "ganesha-namespace" with an object name of "ganesha-config":
#
# %url  rados://nfs-ganesha/ganesha-namespace/ganesha-config
#
# If we only export cephfs (or RGW), store the configs and recovery data in
# RADOS, and mandate NFSv4.1+ for access, we can avoid any sort of local
# storage, and ganesha can run as an unprivileged user (even inside a
# locked-down container).
#

NFS_CORE_PARAM
{
        # Ganesha can lift the NFS grace period early if NLM is disabled.
        Enable_NLM = false;

        # rquotad doesn't add any value here. CephFS doesn't support per-uid
        # quotas anyway.
        Enable_RQUOTA = false;

        # In this configuration, we're just exporting NFSv4. In practice, it's
        # best to use NFSv4.1+ to get the benefit of sessions.
        Protocols = 4;

        mount_path_pseudo = true;
}

NFS_KRB5
{
        Active_krb5 = false;
}

NFSv4
{
        # Modern versions of libcephfs have delegation support, though they
                # are not currently recommended in clustered configurations. They are
        # disabled by default but can be re-enabled for singleton or
        # active/passive configurations.
        # Delegations = false;

        # One can use any recovery backend with this configuration, but being
        # able to store it in RADOS is a nice feature that makes it easy to
        # migrate the daemon to another host.
        #
        # For a single-node or active/passive configuration, rados_ng driver
        # is preferred. For active/active clustered configurations, the
        # rados_cluster backend can be used instead. See the
        # ganesha-rados-grace manpage for more information.
        RecoveryBackend = rados_cluster;

        # NFSv4.0 clients do not send a RECLAIM_COMPLETE, so we end up having
        # to wait out the entire grace period if there are any. Avoid them.
        Minor_Versions =  1,2;
}

# The libcephfs client will aggressively cache information while it
# can, so there is little benefit to ganesha actively caching the same
# objects. Doing so can also hurt cache coherency. Here, we disable
# as much attribute and directory caching as we can.
MDCACHE {
        # Size the dirent cache down as small as possible.
        Dir_Chunk = 0;

        # size the inode cache as small as possible
        NParts = 1;
        Cache_Size = 1;
}

EXPORT
{
        # Unique export ID number for this export
        Export_ID=100;

        # We're only interested in NFSv4 in this configuration
        Protocols = 4;

        # NFSv4 does not allow UDP transport
        Transports = TCP;

        #
        # Path into the cephfs tree.
        #
        # Note that FSAL_CEPH does not support subtree checking, so there is
        # no way to validate that a filehandle presented by a client is
        # reachable via an exported subtree.
        #
        # For that reason, we just export "/" here.
        Path = /;

        #
        # The pseudoroot path. This is where the export will appear in the
        # NFS pseudoroot namespace.
        #
        Pseudo = /Media/;

        # We want to be able to read and write
        Access_Type = RW;

        # Time out attribute cache entries immediately
        Attr_Expiration_Time = 0;

        # Enable read delegations? libcephfs v13.0.1 and later allow the
        # ceph client to set a delegation. While it's possible to allow RW
        # delegations it's not recommended to enable them until ganesha
        # acquires CB_GETATTR support.
        #
        # Note too that delegations may not be safe in clustered
        # configurations, so it's probably best to just disable them until
        # this problem is resolved:
        #
        # http://tracker.ceph.com/issues/24802
        #
        # Delegations = R;

        # NFS servers usually decide to "squash" incoming requests from the
        # root user to a "nobody" user. It's possible to disable that, but for
        # now, we leave it enabled.
        # Squash = root;
        Squash = No_Root_Squash;

        FSAL {
                # FSAL_CEPH export
                Name = CEPH;

                #
                # Ceph filesystems have a name string associated with them, and
                # modern versions of libcephfs can mount them based on the
                # name. The default is to mount the default filesystem in the
                # cluster (usually the first one created).
                #
                Filesystem = "ceph_backups";

                #
                # Ceph clusters have their own authentication scheme (cephx).
                # Ganesha acts as a cephfs client. This is the client username
                # to use. This user will need to be created before running
                # ganesha.
                #
                # Typically ceph clients have a name like "client.foo". This
                # setting should not contain the "client." prefix.
                #
                # See:
                #
                # http://docs.ceph.com/docs/jewel/rados/operations/user-management/
                #
                # The default is to set this to NULL, which means that the
                # userid is set to the default in libcephfs (which is
                # typically "admin").
                #
                User_ID = "nfs-ganesha";

                #
                # Key to use for the session (if any). If not set, it uses the
                # normal search path for cephx keyring files to find a key:
                #
                # Secret_Access_Key = "YOUR SECRET KEY HERE";
        }
}

# Config block for FSAL_CEPH
CEPH
{
        # Path to a ceph.conf file for this ceph cluster.
        # Ceph_Conf = /etc/ceph/ceph.conf;

        # User file-creation mask. These bits will be masked off from the unix
        # permissions on newly-created inodes.
        # umask = 0;
}

LOG {
    Components {
        ALL = INFO;
    }
}


#
# This is the config block for the RADOS RecoveryBackend. This is only
# used if you're storing the client recovery records in a RADOS object.
#
RADOS_KV
{
        # Path to a ceph.conf file for this cluster.
        Ceph_Conf = /etc/ceph/ceph.conf;

        # The recoverybackend has its own ceph client. The default is to
        # let libcephfs autogenerate the userid. Note that RADOS_KV block does
        # not have a setting for Secret_Access_Key. A cephx keyring file must
        # be used for authenticated access.
        UserId = "admin";

        # Pool ID of the ceph storage pool that contains the recovery objects.
        # The default is "nfs-ganesha".
        pool = "nfs-ganesha";

        # Recovery namespace to keep files seperate
        namespace = "ganesha-namespace";

        # Consider setting a unique nodeid for each running daemon here,
        # particularly if this daemon could end up migrating to a host with
        # a different hostname (i.e. if you're running an active/passive cluster
        # with rados_ng/rados_kv and/or a scale-out rados_cluster). The default
        # is to use the hostname of the node where ganesha is running.
        # nodeid = hostname.example.com;
}
```

2. "Put" the config file into the rados block. Most people used namespaces to keep things seperate. This command assumes there is an admin keyring available on the client.

```
rados -p nfs-ganesha -N ganesha-namespace put ganesha.conf /etc/ganesha/ceph.conf
```

3. Create the `rados_url` config file. Store it in `/etc/ganesha/ganesha.conf`

The `rados_url` format is `rados://$POOL-NAME/$NAMESPACE/$FILENAME`
The `%url` will merge the ganesha.conf file stored in Ceph into this file at start of service

```
# Config block for rados:// URL access. It too uses its own client to access
# the object, separate from the FSAL_CEPH and RADOS_KV client.
RADOS_URLS
{
        # Path to a ceph.conf file for this cluster.
        # Ceph_Conf = /etc/ceph/ceph.conf;

        # RADOS_URLS use their own ceph client too. Authenticated access
        # requires a cephx keyring file.
        UserId = "admin";

        # We can also have ganesha watch a RADOS object for notifications, and
        # have it force a configuration reload when one comes in. Set this to
        # a valid rados:// URL to enable this feature.
        watch_url = "rados://nfs-ganesha/ganesha-namespace/ganesha.conf";
}

%url rados://nfs-ganesha/ganesha-namespace/ganesha.conf
```
4. Ganesha Grace Database/Rados Namespace to store Grace db objects
Be sure to use the same pool and namespace as defined in the ganesha.conf on each NFS gateway. 
Specify every NFS gateway in the clusters `nodeid`. `nodeid` defaults to the server's hostname.

```
ganesha-rados-grace -p nfs-ganesha -n ganesha-namespace add nfs1 nfs2 nfs3
```

Check grace db status with:
```
ganesha-rados-grace -p nfs-ganesha -n ganesha-namespace
```
This will create the objects that it needs to function. There will be an object called "grace". Each NFS gateway also has its on set of recovery objects. One for each epoch transition 


5. Restart NFS-Ganesha service

```
sudo systemctl enable nfs-ganesha
sudo systemctl start nfs-ganesha
```


## Mount on remote client

```
sudo mount -v -t nfs -o nfsvers=4.1,proto=tcp $NFS_SERVER:$Pseudo_VALUE_IN_CONFIG $MOUNT
```




### Source Info

Below is where I pieced together this info needed

- http://images.45drives.com/ceph/cephfs/nfs-ganesha-ceph.conf
- https://bugzilla.redhat.com/show_bug.cgi?id=1486112
- https://docs.ceph.com/en/latest/man/8/rados/
- https://forum.proxmox.com/threads/ha-nfs-service-for-kvm-vms-on-a-proxmox-cluster-with-ceph.80967/
- https://github.com/nfs-ganesha/nfs-ganesha/blob/next/src/config_samples/ceph.conf
- https://github.com/nfs-ganesha/nfs-ganesha
- https://pve.proxmox.com/wiki/User:Grin/Ceph_Object_Gateway
- https://docs.ceph.com/en/latest/cephfs/nfs/
- https://documentation.suse.com/ses/5.5/html/ses-all/cha-ceph-nfsganesha.html
- http://mykb.mife.ca/post/ceph-ganesha/
- https://manpages.ubuntu.com/manpages/jammy/man8/ganesha-rados-grace.8.html
- Ganesha's libre.chat IRC channel #ganesha

