1. ceph with helm
```sh
helm repo add ceph-csi https://ceph.github.io/csi-charts
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

3. install cephfs-cli with helm
```sh
# helm v3
kubectl create namespace ceph-csi-cephfs
helm install --namespace "ceph-csi-cephfs" "ceph-csi-cephfs" ceph-csi/ceph-csi-cephfs
```

4. (Optional) if you want to update chart
```sh
helm repo update ceph-csi
helm upgrade --namespace ceph-csi-cephfs ceph-csi-cephfs ceph-csi/ceph-csi-cephfs # cephfs
helm upgrade --namespace ceph-csi-rbd ceph-csi-rbd ceph-csi/ceph-csi-rbd # rbd
```

5. (Optional) if you want to delete chart
```sh
helm uninstall "ceph-csi-cephfs" --namespace "ceph-csi-cephfs"
kubectl delete namespace ceph-csi-cephfs
```

6. check ceph resources on k8s-cluster
```sh
k get all -n ceph-csi-cephfs

NAME                                               READY   STATUS    RESTARTS   AGE
pod/ceph-csi-cephfs-nodeplugin-74ssq               3/3     Running   0          26m
pod/ceph-csi-cephfs-nodeplugin-97rct               3/3     Running   0          26m
pod/ceph-csi-cephfs-nodeplugin-j5qcd               3/3     Running   0          26m
pod/ceph-csi-cephfs-nodeplugin-sj7lc               3/3     Running   0          26m
pod/ceph-csi-cephfs-provisioner-56c77b6469-dcmhc   5/5     Running   0          26m
pod/ceph-csi-cephfs-provisioner-56c77b6469-n7llq   5/5     Running   0          26m
pod/ceph-csi-cephfs-provisioner-56c77b6469-s4hxc   5/5     Running   0          26m

NAME                                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/ceph-csi-cephfs-nodeplugin-http-metrics    ClusterIP   x.x.x.x         <none>        8080/TCP   2m34s
service/ceph-csi-cephfs-provisioner-http-metrics   ClusterIP   x.x.x.x         <none>        8080/TCP   2m34s

NAME                                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/ceph-csi-cephfs-nodeplugin   4         4         0       4            0           <none>          2m34s

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ceph-csi-cephfs-provisioner   0/3     3            0           2m34s

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/ceph-csi-cephfs-provisioner-56c77b6469   3         3         0       2m33s
```