#!/bin/bash

set -a
source "./../.env"
set +a

#Define the application as a Conjur host in policy
envsubst < policies/app-host.yml > app-host.yml.tmp
conjur policy update -f app-host.yml.tmp -b data
rm app-host.yml.tmp

envsubst < policies/grant-app-access.yaml > grant-app-access.yaml.tmp
conjur policy update -f grant-app-access.yaml.tmp -b conjur/authn-jwt/$CONJUR_AUTHENTICATOR_ID
rm grant-app-access.yaml.tmp

envsubst < policies/safe-access.yaml > safe-access.yaml.tmp
conjur policy update -f safe-access.yaml.tmp -b data
rm safe-access.yaml.tmp

# Case of Secrets in Conjur
envsubst < policies/app-secrets.yml > app-secrets.yml.tmp
conjur policy update -b data -f app-secrets.yml.tmp
rm app-secrets.yml.tmp
# Set variables
conjur variable set -i "$APP_SECRET_URL_PATH" -v jdbc:h2:mem:testdb -b data
conjur variable set -i "$APP_SECRET_USERNAME_PATH" -v user -b data
conjur variable set -i "$APP_SECRET_PASSWORD_PATH" -v pass -b data
conjur variable set -i "$APP_SECRETLESS_DB_HOST_PATH" -v "$APP_DB_NAME_POSTGRESQL"."$APP_NAMESPACE".svc.cluster.local -b data
conjur variable set -i "$APP_SECRETLESS_DB_PORT_PATH" -v 5432 -b data
conjur variable set -i "$APP_SECRETLESS_DB_USERNAME_PATH" -v "$APP_POSTGRESQL_USER" -b data
conjur variable set -i "$APP_SECRETLESS_DB_PASSWORD_PATH" -v "$APP_POSTGRESQL_PASSWORD" -b data
conjur variable set -i "$APP_SECRETLESS_DB_MYSQL_HOST_PATH" -v "$APP_DB_NAME_MYSQL"."$APP_NAMESPACE".svc.cluster.local -b data
conjur variable set -i "$APP_SECRETLESS_DB_MYSQL_PORT_PATH" -v 3306 -b data
conjur variable set -i "$APP_SECRETLESS_DB_MYSQL_USERNAME_PATH" -v "$APP_MYSQL_USER" -b data
conjur variable set -i "$APP_SECRETLESS_DB_MYSQL_PASSWORD_PATH" -v "$APP_MYSQL_PASSWORD" -b data
conjur variable set -i "$APP_MONGO_HOST_URI" -v "$APP_MONGO_URI" -b data
