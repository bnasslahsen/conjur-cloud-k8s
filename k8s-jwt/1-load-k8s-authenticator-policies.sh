#!/bin/bash

set -a
source "./../.env"
set +a


# Create BNL ROOT Branch - AS Security Admin
#conjur policy update -b data -f policies/root-branch.yml

# Create K8S Branch - AS Security Admin
envsubst < policies/k8s-branch.yml > policies/k8s-branch.yml.tmp
conjur policy update -b data/bnl -f policies/k8s-branch.yml.tmp
rm policies/k8s-branch.yml.tmp

# Delegation on the branch for the team - AS Security Admin
envsubst < policies/k8s-user-grants.yml > policies/k8s-user-grants.yml.tmp
conjur policy update -b data/vault -f policies/k8s-user-grants.yml.tmp
rm policies/k8s-user-grants.yml.tmp

#Set up a Kubernetes Authenticator endpoint in Conjur
envsubst < policies/k8s-authn-jwt.yml > k8s-authn-jwt.yml.tmp
conjur policy update -f k8s-authn-jwt.yml.tmp -b conjur/authn-jwt
rm k8s-authn-jwt.yml.tmp

#Enable the JWT Authenticator in Conjur Cloud
conjur authenticator enable --id authn-jwt/$CONJUR_AUTHENTICATOR_ID