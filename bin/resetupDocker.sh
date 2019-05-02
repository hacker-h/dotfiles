#!/bin/bash
RAM=4096
DISK=50000
CPU_CORES=2
MACHINE_NAME="mymachine"

set -eu
SILENT=""
#SILENT="> /dev/nul 2> /dev/nul"

if [[ "$OSTYPE" != "msys" ]]; then
	echo "This script is for Windows' Git Bash only."
	exit 1
fi

function isInstalled {
    eval $(echo "which ${1} ${SILENT}")
}

function installIfRequired {
    isInstalled ${1} || (echo "Installing ${1}." && choco install "${1}" -y)
}

isInstalled choco || (echo "Chocolatey is not installed. Aborting." && exit 1)

installIfRequired docker

installIfRequired docker-machine

if docker-machine ls | grep "${MACHINE_NAME}"
then
    echo "Purging existing machine.."
    eval $(echo "docker-machine stop "${MACHINE_NAME}" ${SILENT} || true")
    eval $(echo "docker-machine rm "${MACHINE_NAME}" -f ${SILENT} || true")
    eval $(echo "rm -rf ~/.docker ${SILENT}")
else
    echo "No machine existing yet."
fi
echo "Creating new machine.."
docker-machine create -d virtualbox --virtualbox-cpu-count="${CPU_CORES}" --virtualbox-memory="${RAM}" --virtualbox-disk-size="${DISK}" "${MACHINE_NAME}"

docker-machine regenerate-certs "${MACHINE_NAME}" -f

eval $(docker-machine env --shell bash "${MACHINE_NAME}")

echo "configuring docker ip"
DOCKER_IP=$(docker-machine ip "${MACHINE_NAME}")
setx DOCKER_HOST "tcp://${DOCKER_IP}:2376"

echo "Docker is now installed and ready to use."
