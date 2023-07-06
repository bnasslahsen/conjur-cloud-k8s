#!/bin/bash

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

kubectl delete serviceaccount demo-app-push-to-file-sidecar-sa --ignore-not-found=true
kubectl create serviceaccount demo-app-push-to-file-sidecar-sa

kubectl delete configmap spring-boot-templates --ignore-not-found=true
kubectl create configmap spring-boot-templates --from-file=demo-app.tpl

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment demo-app-push-to-file-sidecar --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services demo-app-push-to-file-sidecar
kubectl get pods
