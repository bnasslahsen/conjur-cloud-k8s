#!/bin/bash

set -a
source "./../../../../.env"
set +a

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete serviceaccount "$APP_PUSH_FILE_SIDECAR"-sa --ignore-not-found=true
$K8S_CLI create serviceaccount "$APP_PUSH_FILE_SIDECAR"-sa

$K8S_CLI delete configmap spring-boot-templates --ignore-not-found=true
$K8S_CLI create configmap spring-boot-templates --from-file=test-app.tpl

# DEPLOYMENT
envsubst < deployment.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_PUSH_FILE_SIDECAR" --for condition=Available=True --timeout=90s
  then exit 1
fi

$K8S_CLI get services "$APP_PUSH_FILE_SIDECAR"
$K8S_CLI get pods
