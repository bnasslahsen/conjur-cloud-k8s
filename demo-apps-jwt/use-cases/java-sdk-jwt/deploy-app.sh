#!/bin/bash

set -a
source "./../../../.env"
set +a

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete serviceaccount "$APP_JAVA_SDK_JWT"-sa --ignore-not-found=true
$K8S_CLI create serviceaccount "$APP_JAVA_SDK_JWT"-sa

kubectl delete configmap conjur-connect-spring-jwt --ignore-not-found=true

openssl s_client -connect "$CONJUR_MASTER_HOSTNAME":"$CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > "$CONJUR_SSL_CERTIFICATE"

cat ./../../../conjur-cloud-ca >> "$CONJUR_SSL_CERTIFICATE"

$K8S_CLI create configmap conjur-connect-spring-jwt \
  --from-literal SPRING_PROFILES_ACTIVE=secured-java \
  --from-literal CONJUR_ACCOUNT="$CONJUR_ACCOUNT" \
  --from-literal CONJUR_APPLIANCE_URL="$CONJUR_APPLIANCE_URL" \
  --from-literal CONJUR_AUTHENTICATOR_ID="$CONJUR_AUTHENTICATOR_ID"  \
  --from-literal CONJUR_JWT_TOKEN_PATH="/var/run/secrets/kubernetes.io/serviceaccount/token" \
  --from-literal LOGGING_LEVEL_COM_CYBERARK=DEBUG  \
  --from-literal SPRING_MAIN_CLOUD_PLATFORM="NONE" \
  --from-file "CONJUR_SSL_CERTIFICATE=conjur.pem" \
  --from-literal SPRING_SQL_INIT_PLATFORM="mysql" \
  --from-literal DB_SECRET_ADDRESS="data/vault/bnl-ocp-safe/mysql-test-db/address" \
  --from-literal DB_SECRET_PORT="data/vault/bnl-ocp-safe/mysql-test-db/Port" \
  --from-literal DB_SECRET_DATABASE="data/vault/bnl-ocp-safe/mysql-test-db/Database" \
  --from-literal DB_SECRET_USERNAME="data/vault/bnl-ocp-safe/mysql-test-db/username" \
  --from-literal DB_SECRET_PASSWORD="data/vault/bnl-ocp-safe/mysql-test-db/password"

# DEPLOYMENT
envsubst < deployment.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_JAVA_SDK_JWT" --for condition=Available=True --timeout=90s
  then exit 1
fi

$K8S_CLI get services "$APP_JAVA_SDK_JWT"
$K8S_CLI get pods

rm "$CONJUR_SSL_CERTIFICATE"
