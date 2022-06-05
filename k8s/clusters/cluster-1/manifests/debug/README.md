# Keeping common commands here because I have tokeep redoing this shit

```
apt-get update && apt-get install openssh-client rsync

rsync --info=progress2 -zarh carpenam@10.10.200.240:/mnt/NFS/Merged-Media/downloads/Plex_backup/Plex_20220331.tar /mountedPVC/Plex_20220331.tar

rsync --info=progress2 -zarh carpenam@10.10.200.240:/mnt/NFS/Merged-Media/downloads/Plex_backup/Plex_20220331.tar /mountedPVC/Plex_20220331.tar

tar -xvf Plex_20220331.tar
```
