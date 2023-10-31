#!/bin/bash

set -a
source ".env"
set +a

policy_file=$(mktemp)

# Clean application group
cat <<EOF >"$policy_file"
- !delete
  record: !policy $APP_GROUP
EOF
conjur policy update -b data -f $policy_file

# Clean Authenticator
cat <<EOF >"$policy_file"
- !delete
  record: !policy $CONJUR_AUTHENTICATOR_ID
EOF
conjur policy update -b conjur/authn-azure -f $policy_file
