#!/bin/bash

set -a
source "./../.env"
set +a

# Create AZURE Branch
conjur policy update -b data -f <(envsubst < k8s-branch.yml)

#Set up a Kubernetes Authenticator endpoint in Conjur
conjur policy update -b conjur/authn-jwt -f <(envsubst < k8s-authn-jwt.yml)

#Enable the JWT Authenticator in Conjur Cloud
conjur authenticator enable --id authn-jwt/$CONJUR_AUTHENTICATOR_ID

kubectl get --raw $(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') > jwks.json
SA_ISSUER="$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')"

conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/public-keys -v "{\"type\":\"jwks\", \"value\":$(cat jwks.json)}"
conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/issuer -v $SA_ISSUER
conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/token-app-property -v "sub"
conjur variable set -i conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID/identity-path -v data/$APP_GROUP

rm jwks.json