#!/bin/bash

set -a
source "./../.env"
set +a


conjur policy update -b data/$APP_GROUP -f <(envsubst < k8s-hosts.yml)

conjur policy update -b data/vault/bnl-k8s-safe -f <(envsubst < k8s-hosts-grants.yml)
