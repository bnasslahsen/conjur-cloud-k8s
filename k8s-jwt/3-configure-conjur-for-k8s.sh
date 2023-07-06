#!/bin/bash

set -a
source "./../.env"
source "$CONJUR_K8S_INFO"
set +a

conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/public-keys -v "{\"type\":\"jwks\", \"value\":$(cat jwks.json)}"
conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/issuer -v $SA_ISSUER
conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/token-app-property -v "sub"
conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/identity-path -v $APP_NAME_BASE_PATH