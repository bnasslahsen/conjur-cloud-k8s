#!/bin/bash

set -a
source "./../../../../.env"
set +a

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete serviceaccount "$APP_NAME_SECRETLESS_MYSQL"-sa --ignore-not-found=true
$K8S_CLI create serviceaccount "$APP_NAME_SECRETLESS_MYSQL"-sa

# DB SECRETLESS CONFIGMAP
$K8S_CLI delete configmap secretless-config-mysql --ignore-not-found=true
envsubst < secretless.template.yml > secretless.yml
$K8S_CLI create configmap secretless-config-mysql  --from-file=secretless.yml
rm secretless.yml

# DB DEPLOYMENT
envsubst < db.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_DB_NAME_MYSQL" --for condition=Available=True --timeout=120s
  then exit 1
fi

# APP DEPLOYMENT
envsubst < deployment.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_NAME_SECRETLESS_MYSQL" --for condition=Available=True --timeout=90s
  then exit 1
fi

$K8S_CLI get services "$APP_NAME_SECRETLESS_MYSQL"
$K8S_CLI get pods
