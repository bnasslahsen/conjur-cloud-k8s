#!/bin/bash

set -a
source "./../.env"
set +a

$K8S_CLI create namespace "$APP_NAMESPACE" --dry-run=client -o yaml | $K8S_CLI apply -f -

$K8S_CLI config set-context --current --namespace="$APP_NAMESPACE"

$K8S_CLI delete configmap conjur-connect --ignore-not-found=true

openssl s_client -connect "$CONJUR_MASTER_HOSTNAME":"$CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > "$CONJUR_SSL_CERTIFICATE"

cat ./../conjur-cloud-ca >> "$CONJUR_SSL_CERTIFICATE"

$K8S_CLI create configmap conjur-connect \
  --from-literal CONJUR_ACCOUNT="$CONJUR_ACCOUNT" \
  --from-literal CONJUR_APPLIANCE_URL="$CONJUR_APPLIANCE_URL" \
  --from-literal CONJUR_AUTHN_URL="$CONJUR_APPLIANCE_URL"/authn-jwt/"$CONJUR_AUTHENTICATOR_ID" \
  --from-literal AUTHENTICATOR_ID="$CONJUR_AUTHENTICATOR_ID" \
  --from-literal CONJUR_AUTHN_JWT_SERVICE_ID="$CONJUR_AUTHENTICATOR_ID" \
  --from-literal MY_POD_NAMESPACE="$APP_NAMESPACE"\
  --from-file "CONJUR_SSL_CERTIFICATE=$CONJUR_SSL_CERTIFICATE"

rm "$CONJUR_SSL_CERTIFICATE"
