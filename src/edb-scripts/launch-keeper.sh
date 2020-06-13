#!/usr/bin/env bash

set -x
echo "Keeper Launch Script V1.1.1"
export POD_NAME=${HOSTNAME}
export POD_IP=$(hostname -i)
export STKEEPER_PG_LISTEN_ADDRESS=$POD_IP
if [[ $STKEEPER_EPAS == "true" ]]; then
  echo "Running with EDB Advanced Server"
  edb-stolon-keeper --EPAS=true
else
  echo "Running with Postgres Community"
  edb-stolon-keeper --EPAS=false
fi
