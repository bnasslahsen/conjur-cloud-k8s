#!/bin/bash
#  helm install external-secrets external-secrets/external-secrets -n bnl-demo-app-ns -f values.yml

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

kubectl delete serviceaccount "$APP_NAME-eso-sa" --ignore-not-found=true
kubectl create serviceaccount "$APP_NAME-eso-sa"

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment "$APP_NAME-eso" --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services "$APP_NAME-eso"
kubectl get pods