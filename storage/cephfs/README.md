1. ceph with helm
```sh
helm repo add ceph-csi https://ceph.github.io/csi-charts

# if you want upgrade chart
helm repo update ceph-csi

helm upgrade --namespace ceph-csi-rbd ceph-csi-rbd ceph-csi/ceph-csi-rbd # rbd
helm upgrade --namespace ceph-csi-cephfs ceph-csi-cephfs ceph-csi/ceph-csi-cephfs # cephfs
```

2. configure cluster monitor first
```yaml
values.yaml

csiConfig:
- clusterID: 'homelab-cluster'
  monitors:  # fill in the monitor hosts
    - ''
    - ''
    - ''
```