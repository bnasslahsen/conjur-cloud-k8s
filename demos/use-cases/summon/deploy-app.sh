#!/bin/bash

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

openssl s_client -connect "$CONJUR_MASTER_HOSTNAME":"$CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > "conjur.pem"


kubectl delete configmap conjur-connect-summon --ignore-not-found=true
kubectl create configmap conjur-connect-summon \
  --from-literal CONJUR_ACCOUNT="$CONJUR_ACCOUNT" \
  --from-literal CONJUR_APPLIANCE_URL="$CONJUR_APPLIANCE_URL" \
  --from-literal CONJUR_AUTHN_URL="$CONJUR_APPLIANCE_URL"/authn-jwt/"$CONJUR_AUTHENTICATOR_ID" \
  --from-literal CONJUR_AUTHN_JWT_SERVICE_ID="$CONJUR_AUTHENTICATOR_ID" \
  --from-literal CONJUR_AUTHENTICATOR_ID="$CONJUR_AUTHENTICATOR_ID"  \
  --from-literal CONJUR_JWT_TOKEN_PATH="/var/run/secrets/kubernetes.io/serviceaccount/token" \
  --from-file "CONJUR_SSL_CERTIFICATE=conjur.pem" \

kubectl delete serviceaccount $APP_NAME-summon-init-sa --ignore-not-found=true
kubectl create serviceaccount $APP_NAME-summon-init-sa

# SUMMON CONFIGMAP
kubectl delete configmap summon-config-init --ignore-not-found=true
envsubst < secrets.template.yml > secrets.yml
kubectl create configmap summon-config-init --from-file=secrets.yml
rm secrets.yml

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment $APP_NAME-summon-init --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services $APP_NAME-summon-init
kubectl get pods

rm conjur.pem