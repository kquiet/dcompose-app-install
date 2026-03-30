#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/utility/vars_functions.sh"

# project name of docker compose
PROJECT="dcompose-app-install"

mkdir -p "${APP_IMAGE_PATH}"

# Get the image list and loop through each one
docker compose -p $PROJECT images | tail -n +2 | awk '{print $2":"$3}' | sort -u | while read -r IMAGE; do
    
    # Replace slashes and colons with underscores for a valid filename
    FILENAME=$(echo $IMAGE | sed 's/[\/:]/_/g').tar
    
    echo "Saving $IMAGE to ${APP_IMAGE_PATH}/$FILENAME..."
    
    # save image
    docker save -o "${APP_IMAGE_PATH}/$FILENAME" "$IMAGE"
    chmod 644 "${APP_IMAGE_PATH}/$FILENAME"
done

echo "Done! All images are saved in the ${APP_IMAGE_PATH} folder."
