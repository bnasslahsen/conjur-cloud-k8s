#!/bin/bash

set -a
source "./../../../.env"
set +a

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete serviceaccount "$APP_SERVICE_ACCOUNT_NAME" --ignore-not-found=true
$K8S_CLI create serviceaccount "$APP_SERVICE_ACCOUNT_NAME"

# DB SECRETS
kubectl delete secret db-credentials --ignore-not-found=true
kubectl create secret generic db-credentials \
    --from-literal=url=jdbc:h2:mem:testdb \
    --from-literal=username=h2-user  \
    --from-literal=password=

# DEPLOYMENT
envsubst < deployment.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_NAME" --for condition=Available=True --timeout=90s
  then exit 1
fi

$K8S_CLI get services "$APP_NAME"
$K8S_CLI get pods