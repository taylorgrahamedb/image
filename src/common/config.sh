#!/bin/bash
set -x

export

SQL_ASCII='SQL_ASCII'
CSET=${CHARSET:-SQL_ASCII}

echo "------- config.sh v1.1.2-------------"
if [[ $PGDATA == *"${PGDATA_HOME}"* ]]; then
  echo "Using default data directory"
else
  echo "linking default location to the location defined by PGDATA"
#  rm -rf "${PGDATA_HOME}"/data
  ln -s "${PGDATA}" "${PGDATA_HOME}"/data

fi

if [[ $USING_SECRET != "true" ]]; then
  PG_USER="enterprisedb"
  whoami
fi

echo "${PG_PASSWORD}" > "${PG_ROOT}"/tmp_pwd
set -x

if [[ $EPAS_NO_REDWOOD == "true" ]]; then
  export PGMOD="--no-redwood-compat "
else
  export PGMOD=""
fi

if [ -z "${PG_INITDB}" ]
then
  echo "Running initDB"
  "${PGBIN}"/initdb ${PGMOD} -D "${PGDATA}" -E "${CSET}" -U "${PG_USER}" --pwfile="${PG_ROOT}"/tmp_pwd
else
  echo "Reusing data directory specified no initdb will occur"
fi

echo "Removing the temp password file"
rm -rf "${PG_ROOT}"/tmp_pwd

if [[ $PGDATA_XLOG == *"${PGDATA_HOME}"* ]]; then
  echo "Using default xlog directory"
else
  cp -R "${PGDATA}"/pg_wal/0* "${PGDATA_XLOG}"
  cp -R "${PGDATA}"/pg_wal/ar* "${PGDATA_XLOG}"

  rm -rf "${PGDATA}"/pg_wal
  ln -s "${PGDATA_XLOG}" "${PGDATA}"/pg_wal
fi

if [[ $USE_CONFIGMAP == "true" ]]; then
  # Allow for custom config from a config map
  echo "include_if_exists = '${PG_ROOT}/conf.d/pg_master.conf'" >> "${PGDATA}"/postgresql.conf
  #Copy over the approriate
  mkdir "${PG_ROOT}"/conf.d
  cp /config/pg_master.conf "${PG_ROOT}"/conf.d/
fi

# allow access to the world
echo "host all all 0.0.0.0/0 md5" >> "${PGDATA}"/pg_hba.conf

if [[ $PG_NOSTART == "true" ]]; then
    echo "Something else will start postgres"
else
  echo " Starting Postgres"
  echo -e "listen_addresses = '*'\n" >> ${PGDATA}/postgresql.conf
  "$PGBIN"/pg_ctl stop --mode=immediate
  rm -rf "${PGDATA}"/postmaster.pid
  # go and start the database
  "$PGBIN"/pg_ctl start
fi
