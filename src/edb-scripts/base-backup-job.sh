#!/usr/bin/env bash

CLUSTER_NAME="oscar-test-cluster"
SERVICE_NAME="edb-as"
POD_NAME="edb-as-keeper"

KEEPER_NUMBER="$(stolonctl status --cluster-name oscar-test-cluster --kube-resource-kind configmap --store-backend 'kubernetes' | grep 'Master: ' | awk '{$1=Master; print $2}' | sed 's/keeper//g ')"
echo "keeper number: ${KEEPER_NUMBER}"

FULL_POD_NAME="$POD_NAME-$KEEPER_NUMBER"
echo "FULL POD NAME: ${FULL_POD_NAME}"
