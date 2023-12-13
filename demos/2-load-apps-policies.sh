#!/bin/bash

set -a
source "./../.env"
set +a


conjur policy update -b data/$APP_GROUP -f <(envsubst < k8s-hosts.yml)

conjur policy update -b data/vault/bnl-k8s-safe -f <(envsubst < k8s-hosts-grants.yml)

conjur policy update -b data/$APP_GROUP -f app-secrets.yml

conjur variable set -i "data/bnl-ocp-apps/secrets/demo-app-secrets-provider-sidecar-sa/client-id" -v client1
conjur variable set -i "data/bnl-ocp-apps/secrets/demo-app-secrets-provider-sidecar-sa/client-secret" -v secret3