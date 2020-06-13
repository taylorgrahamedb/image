#!/usr/bin/env bash

set -x

echo "Policing container removing mount directories and setting permissions V1.1"

echo "whoami:Policing: $(whoami)"

echo "Fixing ${PGDATA}"
cd "${PGDATA}" || exit
/usr/bin/sudo -E rm -rf "${PGDATA}"/lost+found

echo "Fixing ${PGDATA_XLOG}"
cd "${PGDATA_XLOG}" || exit
/usr/bin/sudo -E rm -rf "${PGDATA_XLOG}"/lost+found

echo "Fixing ${PGDATA_ARCHIVE}"
cd "${PGDATA_ARCHIVE}" || exit
/usr/bin/sudo -E rm -rf "${PGDATA_ARCHIVE}"/lost+found

/usr/bin/sudo -E chown -R "${PGOWNER}":"${PGOWNER}" "${PGDATA}"
/usr/bin/sudo -E chown -R "${PGOWNER}":"${PGOWNER}" "${PGDATA_XLOG}"
/usr/bin/sudo -E chown -R "${PGOWNER}":"${PGOWNER}" "${PGDATA_ARCHIVE}"
/usr/bin/sudo -E chown -R "${PGOWNER}":"${PGOWNER}" "${PG_ROOT}"


if [ -z "${STKEEPER_DATA_DIR}" ]
then
  echo "Running without HA (Keeper)"
else
  echo "Running with keeper"
  echo "Creating the keeper data directory"
  /usr/bin/sudo -E mkdir -p "${STKEEPER_DATA_DIR}"
  /usr/bin/sudo -E chown -R "${PGOWNER}":"${PGOWNER}" "${STKEEPER_DATA_DIR}"
fi

/usr/bin/sudo -E ln -s "${PGBIN}" /usr/edb/bin


echo "Policing completed"
