# Задание 4. Защита доступа к кластеру Kubernetes


 - владелец продукта
 - бизнес-аналитик
 - разработчик
 - инженер по эксплуатации
 - DevOps-инженер
 - инженер ИБ
 - менеджер



| № | Роль | Полномочия в Kubernetes | Группы пользователей |
|---|------|-------------------------|----------------------|
| 1 | Суперадмин |                         |                         |
| 2 | владелец продукта | [get", "list", "watch"] -> ["pods", "services", "configmaps", "secrets"] | product-owner                   |
| 3 | бизнес-аналитик     |                         | business-analyst                     |
| 4 | разработчик     |                         | developer                     |
| 5 | инженер по эксплуатации     |                         | support-engineer                     |
| 6 | DevOps-инженер     |                         | devops-engineer                     |
| 7 | инженер ИБ     |                         | security-engineer                     |
| 8 | менеджер     |                         | manager                     |


## 1. Суперадмин

В рамках кластера
Доступ ко всем ресурсам.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: super-admin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
- nonResourceURLs: ["*"]  # Доступ к не-ресурсным URL (например, /metrics)
  verbs: ["*"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: super-admin-binding
subjects:
- kind: User
  name: super-admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: super-admin
  apiGroup: rbac.authorization.k8s.io
```


## 2. Владелец продукта

В рамках неймспейса.
Доступ на чтение к ресурсам в своём namespace, но без возможности изменять.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: smart-home
  name: product-owner
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "replicasets"]
  verbs: ["get", "list", "watch"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: product-owner-binding
  namespace: smart-home
subjects:
- kind: User
  name: product-owner
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: product-owner
  apiGroup: rbac.authorization.k8s.io
```


## 3. Бизнес-аналитик

В рамках неймспейса
Доступ к журналам(логам) подов

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: analytics
  name: business-analyst
rules:
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: business-analyst-binding
  namespace: analytics
subjects:
- kind: User
  name: business-analyst
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: business-analyst
  apiGroup: rbac.authorization.k8s.io
```

## 4. Разработчик

В рамках неймспейса
Полный доступ в определенном namespace, за исключением RBAC и управлением кластером.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: developer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "replicasets"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["*"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["*"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: User
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

## 5. Инженер по эксплуатации

В рамках неймспейса
Доступ к мониторингу, логам, управлению Pod'ами, за исключением IAM, secrets.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: support-engineer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "events"]
  verbs: ["get", "list", "watch", "delete", "patch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["get", "list", "watch", "patch"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: support-engineer-binding
  namespace: production
subjects:
- kind: User
  name: support-engineer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: support-engineer
  apiGroup: rbac.authorization.k8s.io
```

# 6. DevOps-инженер

В рамках кластера
Доступ к управлению ресурсами k8s, за исключением IAM, secrets.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: devops-engineer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "persistentvolumes", "persistentvolumeclaims"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["*"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["*"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses", "volumeattachments"]
  verbs: ["*"]
- apiGroups: ["discovery.k8s.io"]
  resources: ["endpointslices"]
  verbs: ["*"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["*"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: devops-engineer-binding
subjects:
- kind: User
  name: devops-engineer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: devops-engineer
  apiGroup: rbac.authorization.k8s.io
```

# 7. Инженер ИБ

В рамках кластера
Доступ к Secrets, RBAC, аудит безопасности.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-engineer
rules:
- apiGroups: [""]
  resources: ["secrets", "serviceaccounts"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]
- apiGroups: ["certificates.k8s.io"]
  resources: ["certificatesigningrequests"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: security-engineer-binding
subjects:
- kind: User
  name: security-engineer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: security-engineer
  apiGroup: rbac.authorization.k8s.io
```

# 8. Менеджер

В рамках неймспейса
Доступ на чтение ресурсов внутри неймспейса

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: manager
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: manager-binding
  namespace: production
subjects:
- kind: User
  name: manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: manager
  apiGroup: rbac.authorization.k8s.io
```