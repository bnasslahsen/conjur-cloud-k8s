#!/bin/bash

set -a
source "./../.env"
set +a


# Create BNL ROOT Branch - AS Security Admin
conjur policy update -b data -f policies/root-branch.yml

# Create AKS Branch - AS Security Admin
conjur policy update -b data/bnl -f policies/aks-branch.yml

# Delegation on the branch for the team - AS Security Admin
conjur policy update -b data/vault -f policies/aks-user-grants.yml

#Set up a Kubernetes Authenticator endpoint in Conjur
envsubst < policies/authn-jwt-aks.yml > authn-jwt-aks.yml.tmp
conjur policy update -f authn-jwt-aks.yml.tmp -b conjur/authn-jwt
rm authn-jwt-aks.yml.tmp

#Enable the JWT Authenticator in Conjur Cloud
conjur authenticator enable --id authn-jwt/$CONJUR_AUTHENTICATOR_ID