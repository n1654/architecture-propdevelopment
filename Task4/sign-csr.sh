#!/usr/bin/env bash

cd k8s-users

USERS=(
  "product-owner"
  "business-analyst"
  "developer"
  "support-engineer"
  "devops-engineer"
  "security-engineer"
  "manager"
  "super-admin"
)

for USER in "${USERS[@]}"; do
  cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USER-csr
spec:
  request: $(cat $USER.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 864000
  usages:
  - client auth
EOF

  kubectl certificate approve $USER-csr

  kubectl get csr $USER-csr -o jsonpath='{.status.certificate}' | base64 --decode > $USER.crt
done