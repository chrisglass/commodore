#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


CLUSTER_NAME=c-ancient-wave-9394


PROJECT_NAME=ocp4-poc
BASE_DOMAIN=ocp4-poc.appuio-beta.ch
GCP_REGION=europe-west6

LIEUTENANT_URL="api-int.syn.vshn.net"
LIEUTENANT_NS=lieutenant-int
LIEUTENANT_AUTH="Authorization: Bearer $(oc whoami -t)"

# Create install config
cat <<EOF |
apiVersion: v1
metadata:
  name: "${CLUSTER_NAME}"
baseDomain: "${BASE_DOMAIN}"
compute:
- name: worker
  platform:
    gcp:
      type: n1-standard-4
  replicas: 3
controlPlane:
  name: master
  platform:
    gcp:
      type: n1-standard-4
  replicas: 3
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  gcp:
    projectID: "${PROJECT_NAME}"
    region: "${GCP_REGION}"
EOF
kubectl create secret generic "${CLUSTER_NAME}-install-config" \
  --namespace hive \
  --from-file install-config.yaml=/dev/stdin

# Create cluster
kubectl create \
  --namespace hive \
  -f - <<EOF
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: "${CLUSTER_NAME}"
spec:
  baseDomain: "${BASE_DOMAIN}"
  clusterName: "${CLUSTER_NAME}"
  platform:
    gcp:
      credentialsSecretRef:
        name: gcp-poc-service-account
      region: "${GCP_REGION}"
  provisioning:
    imageSetRef:
      name: openshift-v4.4.3
    installConfigSecretRef:
      name: "${CLUSTER_NAME}-install-config"
    SSHPrivateKeySecretRef:
      name: gcp-poc-ssh-key
EOF

# Cluster info
kubectl -n hive describe cd ${CLUSTER_NAME} | grep ID

poetry run commodore catalog compile ${CLUSTER_NAME}

# Access cluster
kubectl -n hive get cd ${CLUSTER_NAME} -o jsonpath='{ .status.webConsoleURL }' | sed

kubectl -n hive get secret $(kubectl -n hive get cd ${CLUSTER_NAME} -o jsonpath='{.spec.clusterMetadata.adminPasswordSecretRef.name}') \
  --output go-template='{{ .data.password | base64decode }}' | xclip

# Reset token
curl -iH "${LIEUTENANT_AUTH}" -H "Content-Type: application/json-patch+json" -X PATCH -d '[{ "op": "remove", "path": "/status/bootstrapToken" }]' "https://rancher.vshn.net/k8s/clusters/c-c6j2w/apis/syn.tools/v1alpha1/namespaces/${LIEUTENANT_NS}/clusters/${CLUSTER_NAME}/status"

# Get install URL
http -pb "https://${LIEUTENANT_URL}/clusters/${CLUSTER_NAME}" "${LIEUTENANT_AUTH}" | jq -r ".installURL"

# SYNFECT 🎉
kubectl apply -f $INSTALL_URL



# Delete cluster
kubectl -n hive delete clusterdeployment ${CLUSTER_NAME} --wait=false
