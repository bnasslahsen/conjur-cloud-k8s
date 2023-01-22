#!/bin/bash

set -a
source "./../.env"
set +a

envsubst < aks-hosts.yml > aks-hosts.yml.tmp
conjur policy update -f aks-hosts.yml.tmp -b data/bnl/aks-team | tee -a aks-hosts.log
rm aks-hosts.yml.tmp

conjur policy update -b data/vault/bnl-aks-safe -f aks-hosts-grants.yml