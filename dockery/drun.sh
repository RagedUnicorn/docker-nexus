#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description run script for docker-nexus container

# abort when trying to use unset variable
set -o nounset

WD="${PWD}"

# variable setup
DOCKER_NEXUS_TAG="ragedunicorn/nexus"
DOCKER_NEXUS_NAME="nexus"
DOCKER_NEXUS_ID=0

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

# check if there is already an image created
docker inspect ${DOCKER_NEXUS_NAME} &> /dev/null

if [ $? -eq 0 ]; then
  # start container
  docker start "${DOCKER_NEXUS_NAME}"
else
  ## run image:
  # -p expose port
  # -d run in detached mode
  # -i Keep STDIN open even if not attached
  # -t Allocate a pseudo-tty
  # --name define a name for the container(optional)
  DOCKER_NEXUS_ID=$(docker run \
  -p 8081:8081 \
  -dit \
  -v nexus-data:/nexus-data \
  --name "${DOCKER_NEXUS_NAME}" "${DOCKER_NEXUS_TAG}")
fi

if [ $? -eq 0 ]; then
  # print some info about containers
  echo "$(date) [INFO]: Container info:"
  docker inspect -f '{{ .Config.Hostname }} {{ .Name }} {{ .Config.Image }} {{ .NetworkSettings.IPAddress }}' ${DOCKER_NEXUS_NAME}
else
  echo "$(date) [ERROR]: Failed to start container - ${DOCKER_NEXUS_NAME}"
fi

cd "${WD}"
