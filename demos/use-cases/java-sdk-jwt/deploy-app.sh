#!/bin/bash

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

kubectl delete serviceaccount $APP_NAME-jwt-sa --ignore-not-found=true
kubectl create serviceaccount $APP_NAME-jwt-sa

kubectl delete configmap conjur-connect-spring-jwt --ignore-not-found=true

openssl s_client -connect "$CONJUR_MASTER_HOSTNAME":"$CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > "conjur.pem"

kubectl create configmap conjur-connect-spring-jwt \
  --from-literal SPRING_PROFILES_ACTIVE=secured-java \
  --from-literal CONJUR_ACCOUNT="$CONJUR_ACCOUNT" \
  --from-literal CONJUR_APPLIANCE_URL="$CONJUR_APPLIANCE_URL" \
  --from-literal CONJUR_AUTHENTICATOR_ID="$CONJUR_AUTHENTICATOR_ID"  \
  --from-literal CONJUR_JWT_TOKEN_PATH="/var/run/secrets/kubernetes.io/serviceaccount/token" \
  --from-literal LOGGING_LEVEL_COM_CYBERARK=DEBUG  \
  --from-literal SPRING_MAIN_CLOUD_PLATFORM="NONE" \
  --from-file "CONJUR_SSL_CERTIFICATE=conjur.pem" 

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment $APP_NAME-jwt --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services $APP_NAME-jwt
kubectl get pods

rm "conjur.pem"
