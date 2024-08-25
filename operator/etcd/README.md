# ETCD Cluster Operator

N 개 이상의 노드로 구성된 ETCD 클러스터를 만든다.
- 엔드포인트, 인증 등을 함께 구성한다.
- https://github.com/coreos/etcd-operator


1. create crd from manifest
```sh
k create -f ./etcd-operator.crd.yaml
```

2. check crd
```sh
k get crd

NAME                                                  CREATED AT
# ...
etcdclusters.etcd.database.coreos.com                 2024-08-25T14:59:07Z
```

3. operator service account
```sh
k create -f ./etcd-operator.sa.yaml

serviceaccount/etcd-operator-sa created
role.rbac.authorization.k8s.io/etcd-operator-role created
rolebinding.rbac.authorization.k8s.io/etcd-operator-rolebinding created
```

4. operator deployment
```sh
k apply -f ./etcd-operator.deployment.yaml

deployment.apps/etcd-operator created
```

5. check deployment
```sh
k get pods
NAME                                                     READY   STATUS            RESTARTS        AGE

# ...
etcd-operator-7449d6b768-zxvqn                           0/2     PodInitializing   0               76s
```