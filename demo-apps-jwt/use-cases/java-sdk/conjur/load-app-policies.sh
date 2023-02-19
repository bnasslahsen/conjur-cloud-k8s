#!/bin/bash

set -a
source "./../../../../.env"
set +a

envsubst < app-host.yml > app-host.yml.tmp
conjur policy update -b data/bnl/$K8S_PLATFORM-team -f app-host.yml.tmp >> app-host.log
rm app-host.yml.tmp