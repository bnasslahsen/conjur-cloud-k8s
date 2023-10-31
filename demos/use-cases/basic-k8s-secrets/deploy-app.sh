#!/bin/bash

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

kubectl delete serviceaccount "$APP_NAME-sa" --ignore-not-found=true
kubectl create serviceaccount "$APP_NAME-sa"

# DB SECRETS
envsubst < k8s-secrets.yml | kubectl replace --force -f -

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment "$APP_NAME" --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services "$APP_NAME"
kubectl get pods