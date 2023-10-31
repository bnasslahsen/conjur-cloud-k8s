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
  --from-file "CONJUR_SSL_CERTIFICATE=conjur.pem" \
  --from-literal SPRING_SQL_INIT_PLATFORM="mysql" \
  --from-literal DB_SECRET_ADDRESS="data/vault/bnl-k8s-safe/mysql-test-db/address" \
  --from-literal DB_SECRET_PORT="data/vault/bnl-k8s-safe/mysql-test-db/Port" \
  --from-literal DB_SECRET_DATABASE="data/vault/bnl-k8s-safe/mysql-test-db/Database" \
  --from-literal DB_SECRET_USERNAME="data/vault/bnl-k8s-safe/mysql-test-db/username" \
  --from-literal DB_SECRET_PASSWORD="data/vault/bnl-k8s-safe/mysql-test-db/password"

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment $APP_NAME-jwt --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services $APP_NAME-jwt
kubectl get pods

rm "conjur.pem"
