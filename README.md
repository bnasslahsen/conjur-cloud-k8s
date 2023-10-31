# Demo project for Conjur integration with OpenShift/Kubernetes

A demo application creating using the Spring Framework. 
This application requires access to an H2 database.

## Pre-requisites
- OS Linux / MacOS
- kubectl / oc
- conjur-cli
- envsubst / openssl
- Clone this git repository
- Conjur Cloud: https://docs-er.cyberark.com/conjurcloud/en/Content/Integrations/k8s-ocp/k8s-jwt-authn.htm


## K8s Setup
- Go to the K8S setup directory:
```shell
cd k8s-jwt
```

- Declare K8s authenticator - AS Conjur Admin
```shell
./load-k8s-authenticator-policies.sh
```


## Configure and deploy the sample applications

- Go to the App setup directory:
```shell
cd demo-apps-jwt
```

- Create the conjur-connect configMap - AS K8S Admin
```shell
./1-configure-apps.sh
```

- Delegation of safe to OCP team  - AS Conjur admin
```shell
2-load-apps-policies.sh
```

- Deploy basic-k8s-secrets - AS App Team
```shell
cd use-cases/basic-k8s-secrets
./deploy-app.sh
```

- Deploy secrets-provider-for-k8s-init - AS App Team
```shell
cd use-cases/secrets-provider-for-k8s-init/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```

- Deploy secrets-provider-for-k8s-sidecar - AS App Team
```shell
cd use-cases/secrets-provider-for-k8s-sidecar/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```

- Deploy summon-init - AS App Team
```shell
cd use-cases/summon-init/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```

- Deploy summon-sidecar - AS App Team
```shell
cd use-cases/summon-sidecar/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```

- Deploy push-to-file - AS App Team
```shell
cd use-cases/push-to-file/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```

- Deploy secretless-mysql - AS App Team
```shell
cd use-cases/secretless-mysql/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```

- Deploy java-sdk - AS App Team
```shell
cd use-cases/java-sdk/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```

- Deploy java-sdk-jwt - AS App Team
```shell
cd use-cases/java-sdk-jwt/conjur
./load-app-policies.sh
cd ../k8s
deploy-app.sh
```