previewHash=$(jq -r '.previewHash' preview_version.json)
quickstartHash=$(jq -r '.quickstartHash' preview_version.json)

previewVersion=$(echo "$previewHash" | cut -d'@' -f1)
echo $previewVersion

PREVIEW_CONTAINER_NAME="soroban-preview-${previewVersion}-malicious"

#!/bin/bash

set -e

case "$1" in
standalone)
    echo "Using standalone network"
    ARGS="--local --enable-soroban-diagnostic-events"
    STELLAR_NAME='stellar-standalone'
    LOCAL_PORT='8000'
    ;;
futurenet)
    echo "Using Futurenet network"
    ARGS="--futurenet"
    STELLAR_NAME='stellar-futurenet'
    LOCAL_PORT='8001'
    ;;
testnet)
    echo "Using Testnet network"
    ARGS="--testnet"
    ;;
*)
    echo "Usage: $0 standalone|futurenet|testnet"
    exit 1
    ;;
esac

shift


echo "1. Creating docker soroban network"
(docker network inspect soroban-network -f '{{.Id}}' 2>/dev/null) \
  || docker network create soroban-network

echo "  "
echo "  "

echo "2. Searching for a previous soroban-preview docker container"
containerID=$(docker ps --filter=`name=${PREVIEW_CONTAINER_NAME}` --all --quiet)
if [[ ${containerID} ]]; then
    echo "Start removing ${PREVIEW_CONTAINER_NAME}  container."
    docker rm --force ${PREVIEW_CONTAINER_NAME}
    echo "Finished removing ${PREVIEW_CONTAINER_NAME} container."
else
    echo "No previous ${PREVIEW_CONTAINER_NAME} container was found"
fi
echo "  "
echo " .. "

currentDir=$(pwd)
docker run -dti \
  --volume ${currentDir}:/workspace \
  --name ${PREVIEW_CONTAINER_NAME} \
  --ipc=host \
  --network soroban-network \
  esteblock/soroban-preview:${previewHash}


echo "2. Running a the stellar quickstart image with name=$STELLAR_NAME"

# Run the stellar quickstart image
docker run --rm -ti \
  --name $STELLAR_NAME \
  --network soroban-network \
  -p $LOCAL_PORT:8000 \
  stellar/quickstart:$quickstartHash \
  $ARGS \
  --enable-soroban-rpc \
  --protocol-version 20 \
  "$@" # Pass through args from the CLI



  #--platform linux/amd64 \

  # docker run --rm -it \
  # -p 8002:8000 \
  # --name stellar-futurenet \
  # stellar/quickstart:soroban-dev@sha256:a057ec6f06c6702c005693f8265ed1261e901b153a754e97cf18b0962257e872 \
  # --futurenet \
  # --enable-soroban-rpc

