#!/bin/sh
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description launch script for nexus

set -euo pipefail

create_data_dir() {
  echo "$(date) [INFO]: Creating data directory ${NEXUS_DATA_DIR} and setting permissions"
  mkdir -p ${NEXUS_DATA_DIR}/etc ${NEXUS_DATA_DIR}/log ${NEXUS_DATA_DIR}/tmp
  chown -R "${NEXUS_USER}":"${NEXUS_GROUP}" "${NEXUS_DATA_DIR}"
}

init() {
  if [ -f  "${NEXUS_DATA_DIR}/.init" ]; then
    echo "$(date) [INFO]: Init script already run - starting Nexus"
    # check if run directory exists
    create_data_dir

    echo "$(date) [INFO]: Starting nexus ..."
    exec su-exec "${NEXUS_USER}" "${NEXUS_HOME}/bin/nexus" run
  else
    echo "$(date) [INFO]: First time setup - running init script"
    create_data_dir

    touch "${NEXUS_DATA_DIR}/.init"
    echo "$(date) [INFO]: Init script done"

    echo "$(date) [INFO]: Starting nexus ..."
    exec su-exec "${NEXUS_USER}" "${NEXUS_HOME}/bin/nexus" run
  fi
}

init
