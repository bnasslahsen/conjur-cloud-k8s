#!/bin/bash

set -a
source "./../../../../.env"
set +a

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete serviceaccount "$APP_SUMMON_SIDECAR"-sa --ignore-not-found=true
$K8S_CLI create serviceaccount "$APP_SUMMON_SIDECAR"-sa

# SUMMON CONFIGMAP
$K8S_CLI delete configmap summon-config-sidecar --ignore-not-found=true
envsubst < secrets.template.yml > secrets.yml
$K8S_CLI create configmap summon-config-sidecar --from-file=secrets.yml
rm secrets.yml

# DEPLOYMENT
envsubst < deployment.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_SUMMON_SIDECAR" --for condition=Available=True --timeout=90s
  then exit 1
fi

$K8S_CLI get services "$APP_SUMMON_INIT"
$K8S_CLI get pods
