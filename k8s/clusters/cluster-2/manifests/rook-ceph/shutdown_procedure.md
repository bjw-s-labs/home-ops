export DOMAIN = "foo.bar"

# Hault Ceph

kubectl rook-ceph  --context cluster-2 ceph osd set noout
kubectl rook-ceph  --context cluster-2 ceph osd set nobackfill
kubectl rook-ceph  --context cluster-2 ceph osd set norecover
kubectl rook-ceph  --context cluster-2 ceph osd set norebalance
kubectl rook-ceph  --context cluster-2 ceph osd set nodown
kubectl rook-ceph  --context cluster-2 ceph osd set pause

# Shutdown non-CP nodes
talosctl --nodes cm4-01.cluster-2.${DOMAIN},cm4-02.cluster-2.${DOMAIN},cm4-03.cluster-2.${DOMAIN} shutdown

talosctl --nodes mon1.cluster-2.${DOMAIN} shutdown
talosctl --nodes n100-01.cluster-2.${DOMAIN},n100-02.cluster-2.${DOMAIN} shutdown

talosctl --nodes work1.cluster-2.${DOMAIN} shutdown
talosctl --nodes work2.cluster-2.${DOMAIN} shutdown
talosctl --nodes work3.cluster-2.${DOMAIN} shutdown
talosctl --nodes work4.cluster-2.${DOMAIN} shutdown
talosctl --nodes work5.cluster-2.${DOMAIN} shutdown
talosctl --nodes work6.cluster-2.${DOMAIN} shutdown
talosctl --nodes work7.cluster-2.${DOMAIN} shutdown
talosctl --nodes work8.cluster-2.${DOMAIN} shutdown
talosctl --nodes work9.cluster-2.${DOMAIN} shutdown
talosctl --nodes work10.cluster-2.${DOMAIN} shutdown
talosctl --nodes work11.cluster-2.${DOMAIN} shutdown

# Shutdown CP Nodes & ceph mons
talosctl --nodes cp1.cluster-2.${DOMAIN},cp2.cluster-2.${DOMAIN},cp3.cluster-2.${DOMAIN} shutdown




# Revert Ceph flags
kubectl rook-ceph  --context cluster-2 ceph osd unset noout
kubectl rook-ceph  --context cluster-2 ceph osd unset nobackfill
kubectl rook-ceph  --context cluster-2 ceph osd unset norecover
kubectl rook-ceph  --context cluster-2 ceph osd unset norebalance
kubectl rook-ceph  --context cluster-2 ceph osd unset nodown
kubectl rook-ceph  --context cluster-2 ceph osd unset pause