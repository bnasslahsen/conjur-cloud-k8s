#!/bin/bash

set -a
source "./../../../../.env"
set +a

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete serviceaccount "$APP_SECRETS_K8S_SIDECAR"-sa --ignore-not-found=true
$K8S_CLI create serviceaccount "$APP_SECRETS_K8S_SIDECAR"-sa

# DB SECRETS
envsubst < k8s-secrets.yml | $K8S_CLI replace --force -f -

# Service account role binding
envsubst < service-account-role.yml | $K8S_CLI replace --force -f -

# DEPLOYMENT
envsubst < deployment.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_SECRETS_K8S_SIDECAR" --for condition=Available=True --timeout=90s
  then exit 1
fi

$K8S_CLI get services "$APP_SECRETS_K8S_SIDECAR"
$K8S_CLI get pods
