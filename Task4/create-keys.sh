#!/usr/bin/env bash

mkdir -p k8s-users && cd k8s-users

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
  openssl genrsa -out $USER.key 2048
  openssl req -new -key $USER.key -out $USER.csr -subj "/CN=$USER/O=kubernetes-users"
done