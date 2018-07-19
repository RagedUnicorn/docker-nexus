#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description stop script for docker-nexus container

set -euo pipefail

WD="${PWD}"

# variable setup
DOCKER_NEXUS_NAME="nexus"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

# search running container
docker ps | grep "${DOCKER_NEXUS_NAME}" > /dev/null

# if container is running - stop it
if [ $? -eq 0 ]; then
  echo "$(date) [INFO]: Stopping container "${DOCKER_NEXUS_NAME}" ..."
  docker stop "${DOCKER_NEXUS_NAME}" > /dev/null
else
  echo "$(date) [INFO]: No running container with name: ${DOCKER_NEXUS_NAME} found"
fi

cd "${WD}"
