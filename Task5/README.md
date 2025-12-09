# Задание 5. Управление трафиком внутри кластера Kubernetes

## Манифесты

[Манифест подов](./sandbox.yaml)

[Манифест сетевых политик](./network-policy.yaml)


## Подготовка

Для тестирования в minikube необходим запуск сетевых плагинов, например calico.

```sh
minikube delete
minikube start --network-plugin=cni --cni=calico

kubectl apply -f sandbox.yaml
kubectl apply -f network-policy.yaml
```
Правила созданы таким образом что:
 
 - разрешены сетевые соединения инициированные на front-end в сторону back-end-api - TCP/80
 - разрешены сетевые соединения инициированные на admin-front-end в сторону admin-back-end-api - TCP/80
 - остальные соединения запрещены


## Проверка

```sh
# ip адреса подов
$ kubectl get pods -A -o wide
NAMESPACE     NAME                                       READY   STATUS    RESTARTS      AGE     IP              NODE       NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-5745477d4d-dcfn9   1/1     Running   1 (28m ago)   28m     10.244.120.66   minikube   <none>           <none>
kube-system   calico-node-rlxnx                          1/1     Running   0             28m     192.168.49.2    minikube   <none>           <none>
kube-system   coredns-668d6bf9bc-4l9lb                   1/1     Running   2 (28m ago)   28m     10.244.120.65   minikube   <none>           <none>
kube-system   etcd-minikube                              1/1     Running   0             28m     192.168.49.2    minikube   <none>           <none>
kube-system   kube-apiserver-minikube                    1/1     Running   0             28m     192.168.49.2    minikube   <none>           <none>
kube-system   kube-controller-manager-minikube           1/1     Running   0             28m     192.168.49.2    minikube   <none>           <none>
kube-system   kube-proxy-6wwqv                           1/1     Running   0             28m     192.168.49.2    minikube   <none>           <none>
kube-system   kube-scheduler-minikube                    1/1     Running   0             28m     192.168.49.2    minikube   <none>           <none>
kube-system   storage-provisioner                        1/1     Running   1 (28m ago)   28m     192.168.49.2    minikube   <none>           <none>
sandbox       admin-back-end-api-app                     1/1     Running   0             9m28s   10.244.120.74   minikube   <none>           <none>
sandbox       admin-front-end-app                        1/1     Running   0             9m28s   10.244.120.73   minikube   <none>           <none>
sandbox       back-end-api-app                           1/1     Running   0             9m28s   10.244.120.72   minikube   <none>           <none>
sandbox       front-end-app                              1/1     Running   0             9m28s   10.244.120.71   minikube   <none>           <none>

# запускаем bash shell внутри пода
$ kubectl exec -it admin-back-end-api-app -n sandbox -- /bin/bash

# проверяем утилитой curl в сторону других подов
root@admin-back-end-api-app:/# curl http://10.244.120.73 --vv
curl: option --vv: is unknown
curl: try 'curl --help' or 'curl --manual' for more information
root@admin-back-end-api-app:/# curl http://10.244.120.73 --vv^C
root@admin-back-end-api-app:/# curl http://10.244.120.73 -vv
*   Trying 10.244.120.73:80...
* connect to 10.244.120.73 port 80 failed: Connection timed out
* Failed to connect to 10.244.120.73 port 80 after 136013 ms: Couldn't connect to server
* Closing connection 0
curl: (28) Failed to connect to 10.244.120.73 port 80 after 136013 ms: Couldn't connect to server

# запускаем bash shell внутри другого пода
$ $ kubectl exec -it front-end-app -n sandbox -- /bin/bash

# проверяем утилитой curl в сторону других подов
root@front-end-app:/# curl http://10.244.120.72
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```