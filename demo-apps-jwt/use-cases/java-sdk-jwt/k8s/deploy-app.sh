#!/bin/bash

set -a
source "./../../../../.env"
set +a

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete serviceaccount "$APP_JAVA_SDK_JWT"-sa --ignore-not-found=true
$K8S_CLI create serviceaccount "$APP_JAVA_SDK_JWT"-sa

$K8S_CLI delete secret generic java-sdk-credentials-jwt --ignore-not-found=true

openssl s_client -connect "$CONJUR_MASTER_HOSTNAME":"$CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > "$CONJUR_SSL_CERTIFICATE"

cat ./../../../../conjur-cloud-ca >> "$CONJUR_SSL_CERTIFICATE"

$K8S_CLI create secret generic java-sdk-credentials-jwt  \
        --from-literal=conjur-service-id="$CONJUR_AUTHENTICATOR_ID"  \
        --from-literal=conjur-account="$CONJUR_ACCOUNT" \
        --from-literal=conjur-jwt-token-path="$CONJUR_JWT_TOKEN_PATH" \
        --from-literal=conjur-appliance-url="$CONJUR_APPLIANCE_URL"  \
        --from-literal=conjur-ssl-cert-base64="$(cat $CONJUR_SSL_CERTIFICATE | base64)"

# DEPLOYMENT
envsubst < deployment.yml | $K8S_CLI replace --force -f -
if ! $K8S_CLI wait deployment "$APP_JAVA_SDK_JWT" --for condition=Available=True --timeout=90s
  then exit 1
fi

$K8S_CLI get services "$APP_JAVA_SDK_JWT"
$K8S_CLI get pods

rm "$CONJUR_SSL_CERTIFICATE"
