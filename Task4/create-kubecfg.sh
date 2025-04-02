#!/usr/bin/env bash

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-name)
      CLUSTER_NAME="$2"
      shift 2
      ;;
    --endpoint)
      CLUSTER_ENDPOINT="$2"
      shift 2
      ;;
    --ca-cert)
      CA_CERT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$CLUSTER_NAME" || -z "$CLUSTER_ENDPOINT" || -z "$CA_CERT" ]]; then
  echo "Usage: $0 --cluster-name <name> --endpoint <url> --ca-cert <path>"
  echo "Example: $0 --cluster-name minikube --endpoint https://127.0.0.0.1:6443 --ca-cert /path/to/ca.crt"
  exit 1
fi

cd k8s-users || exit

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
  kubectl config set-cluster "$CLUSTER_NAME" \
    --server="$CLUSTER_ENDPOINT" \
    --certificate-authority="$CA_CERT" \
    --embed-certs=true \
    --kubeconfig="$USER.kubeconfig"

  kubectl config set-credentials "$USER" \
    --client-certificate="$USER.crt" \
    --client-key="$USER.key" \
    --embed-certs=true \
    --kubeconfig="$USER.kubeconfig"

  kubectl config set-context "$USER-context" \
    --cluster="$CLUSTER_NAME" \
    --user="$USER" \
    --kubeconfig="$USER.kubeconfig"

  kubectl config use-context "$USER-context" \
    --kubeconfig="$USER.kubeconfig"
done

echo "Kubeconfig files generated successfully for cluster: $CLUSTER_NAME"