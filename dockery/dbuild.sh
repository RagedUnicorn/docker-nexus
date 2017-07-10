#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description build script for docker-nexus container

# abort when trying to use unset variable
set -o nounset
set -x

WD="${PWD}"

# variable setup
DOCKER_NEXUS_TAG="ragedunicorn/nexus"
DOCKER_NEXUS_NAME="nexus"
DOCKER_NEXUS_DATA_VOLUME="nexus-data"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

echo "$(date) [INFO]: Building container: ${DOCKER_NEXUS_NAME} - ${DOCKER_NEXUS_TAG}"

# build java container
docker build -t "${DOCKER_NEXUS_TAG}" ../

# check if mariadb data volume already exists
docker volume inspect "${DOCKER_NEXUS_DATA_VOLUME}" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "$(date) [INFO]: Reusing existing volume: ${DOCKER_NEXUS_DATA_VOLUME}"
else
  echo "$(date) [INFO]: Creating new volume: ${DOCKER_NEXUS_DATA_VOLUME}"
  docker volume create --name "${DOCKER_NEXUS_DATA_VOLUME}" > /dev/null
fi

cd "${WD}"
