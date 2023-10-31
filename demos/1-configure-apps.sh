#!/bin/bash

set -a
source "./../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

kubectl delete configmap conjur-connect --ignore-not-found=true

openssl s_client -connect "$CONJUR_MASTER_HOSTNAME":"$CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > conjur.pem

kubectl create configmap conjur-connect \
  --from-literal CONJUR_ACCOUNT="$CONJUR_ACCOUNT" \
  --from-literal CONJUR_APPLIANCE_URL="$CONJUR_APPLIANCE_URL" \
  --from-literal CONJUR_AUTHN_URL="$CONJUR_APPLIANCE_URL"/authn-jwt/"$CONJUR_AUTHENTICATOR_ID" \
  --from-literal AUTHENTICATOR_ID="$CONJUR_AUTHENTICATOR_ID" \
  --from-literal CONJUR_AUTHN_JWT_SERVICE_ID="$CONJUR_AUTHENTICATOR_ID" \
  --from-literal MY_POD_NAMESPACE="$APP_NAMESPACE"\
  --from-file "CONJUR_SSL_CERTIFICATE=conjur.pem"

rm "conjur.pem"