#!/bin/bash

set -a
source "./../.env"
set +a

envsubst < policies/aks-hosts.yml > aks-hosts.yml.tmp
conjur policy update -f aks-hosts.yml.tmp -b data/bnl/aks-team | tee -a aks-hosts.log
rm aks-hosts.yml.tmp

envsubst < policies/aks-hosts-grants.yml > aks-hosts-grants.yml.tmp
conjur policy update -f aks-hosts-grants.yml.tmp -b data/vault/bnl-aks-safe
rm aks-hosts-grants.yml.tmp
