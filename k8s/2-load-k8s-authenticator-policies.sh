#!/bin/bash

set -a
source "./../.env"
set +a

#Set up a Kubernetes Authenticator endpoint in Conjur
envsubst < policies/jwt-authenticator-webservice.yaml > jwt-authenticator-webservice.yaml.tmp
conjur policy update -f jwt-authenticator-webservice.yaml.tmp -b conjur/authn-jwt

conjur policy load