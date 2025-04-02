# Задание 4. Защита доступа к кластеру Kubernetes

## Роли

| № | Роль | Полномочия в Kubernetes | Группы пользователей |
|---|------|-------------------------|----------------------|
| 1 | Суперадмин | привилегии без ограничений. | super-admin |
| 2 | Владелец продукта | В рамках неймспейса. Доступ на чтение к ресурсам в своём namespace, но без возможности изменять. | product-owner |
| 3 | Бизнес-аналитик | В рамках неймспейса. Доступ к журналам(логам) подов. | business-analyst |
| 4 | Разработчик | В рамках неймспейса. Полный доступ в определенном namespace, за исключением RBAC и управлением кластером. | developer |
| 5 | Инженер по эксплуатации | В рамках неймспейса. Доступ к мониторингу, логам, управлению Pod'ами, за исключением IAM, secrets. | support-engineer  |
| 6 | DevOps-инженер | В рамках кластера. Доступ к управлению ресурсами k8s, за исключением IAM, secrets. | devops-engineer |
| 7 | Инженер ИБ | В рамках кластера. Доступ к Secrets, RBAC, аудит безопасности. | security-engineer |
| 8 | Менеджер | В рамках неймспейса. Доступ на чтение ресурсов внутри неймспейса. | manager |

## Скрипты

 - [create-keys.sh](./create-keys.sh)
 - [sign-csr.sh](./sign-csr.sh)
 - [create-kubecfg.sh](./create-kubecfg.sh)

## Манифесты

 - [Манифест для роли суперадмина](./k8s-manifests/super-admin-role.yaml)
 - [Манифест для роли владельца продукта](./k8s-manifests/product-owner-role.yaml)
 - [Манифест для роли бизнес-аналитика](./k8s-manifests/business-analyst-role.yaml)
 - [Манифест для роли разработчика](./k8s-manifests/developer-role.yaml)
 - [Манифест для роли инженера по эксплуатации](./k8s-manifests/support-engineer.yaml)
 - [Манифест для роли DevOps-инженера](./k8s-manifests/devops-engineer-role.yaml)
 - [Манифест для роли инженера ИБ](./k8s-manifests/security-engineer-role.yaml)
 - [Манифест для роли менеджера](./k8s-manifests/security-engineer-role.yaml)



## Создание пользователей

Сначала необходимо создать ключи и запросы на создание сертификатов Certificate Sign Request (CSR).

[create-keys.sh](./create-keys.sh)


```sh
chmod +x ./create-keys.sh
./create-keys.sh

# должна создаться директории с файлами
# проверим, что файлы ключей и CSR создались
$ ls -alh ./k8s-users/
```

Затем k8s должен подписать сертификаты

[sign-csr.sh](./sign-csr.sh)

```sh
chmod +x ./sign-csr.sh
./sign-csr.sh

# увидим, что объекты CSR были созданы в k8s, а затем подтверждены (подписаны)
# здесь же происходит извлечение подписанных сертификатов 
# и сохранение в файлы *.crt в директории ./k8s-users/
certificatesigningrequest.certificates.k8s.io/product-owner-csr created
certificatesigningrequest.certificates.k8s.io/product-owner-csr approved
certificatesigningrequest.certificates.k8s.io/business-analyst-csr created
certificatesigningrequest.certificates.k8s.io/business-analyst-csr approved
certificatesigningrequest.certificates.k8s.io/developer-csr created
certificatesigningrequest.certificates.k8s.io/developer-csr approved
certificatesigningrequest.certificates.k8s.io/support-engineer-csr created
certificatesigningrequest.certificates.k8s.io/support-engineer-csr approved
certificatesigningrequest.certificates.k8s.io/devops-engineer-csr created
certificatesigningrequest.certificates.k8s.io/devops-engineer-csr approved
certificatesigningrequest.certificates.k8s.io/security-engineer-csr created
certificatesigningrequest.certificates.k8s.io/security-engineer-csr approved
certificatesigningrequest.certificates.k8s.io/manager-csr created
certificatesigningrequest.certificates.k8s.io/manager-csr approved
certificatesigningrequest.certificates.k8s.io/super-admin-csr created
certificatesigningrequest.certificates.k8s.io/super-admin-csr approved
```

Создаем файлы kubeconfig для каждого пользователя, 
файлы конфигурации необходимы пользователям для подключения к k8s API

[create-kubecfg.sh](./create-kubecfg.sh)

```sh
chmod +x ./create-kubecfg.sh
./create-kubecfg.sh \
  --cluster-name <MY_MINIKUBE_NAME> \
  --endpoint <MY_MINIKUBE_API> \
  --ca-cert <MY_MINIKUBE_CA.CRT>
```

## Манифесты k8s

Манифесты включают создание:

 - неймспейса (namespace)
 - роли (Role)
 - привязки роли к пользователю (RoleBinding)

Применим манифесты

```sh
kubectl apply -f ./k8s-manifests/business-analyst-role.yaml
kubectl apply -f ./k8s-manifests/devops-engineer-role.yaml
kubectl apply -f ./k8s-manifests/product-owner-role.yaml
kubectl apply -f ./k8s-manifests/super-admin-role.yaml
kubectl apply -f ./k8s-manifests/developer-role.yaml
kubectl apply -f ./k8s-manifests/manager-role.yaml
kubectl apply -f ./k8s-manifests/security-engineer-role.yaml
kubectl apply -f ./k8s-manifests/support-engineer.yaml
```

## Проверка

Выборочно проверим роли и привилегии

```sh
$ kubectl auth can-i get pods --as=developer -n development
yes
$ kubectl auth can-i delete nodes --as=developer
Warning: resource 'nodes' is not namespace scoped

no
```