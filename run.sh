previewHash=$(jq -r '.previewHash' preview_version.json)
previewVersion=$(echo "$previewHash" | cut -d'@' -f1)
PREVIEW_CONTAINER_NAME="soroban-preview-${previewVersion}-malicious"


docker exec -it ${PREVIEW_CONTAINER_NAME} bash
