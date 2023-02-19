#!/bin/bash

set -a
source "./../.env"
set +a

envsubst < k8s-hosts-grants.yml > k8s-hosts-grants.yml.tmp
conjur policy update -b data/vault/bnl-$K8S_PLATFORM-safe -f k8s-hosts-grants.yml.tmp
rm k8s-hosts-grants.yml.tmp
