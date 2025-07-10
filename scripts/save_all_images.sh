#!/bin/bash
#
# This script finds ALL Docker images on the local machine,
# and saves them into a single, timestamped, compressed tarball.
# The output filename will be in the format: all_docker_images_HOSTNAME_YYYYMMDD.tar.gz

set -e

# --- Configuration ---
# Get the directory of this script to run commands from the project root.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"

# Generate a strict, descriptive filename
DATE=$(date +%Y%m%d)
# Fallback for hostname if command fails
HOSTNAME=${HOSTNAME:-$(hostname)}
OUTPUT_FILE="all_docker_images_${HOSTNAME}_${DATE}.tar.gz"

# --- Main Logic ---
cd "$PROJECT_ROOT"

echo "Finding all local Docker images (excluding <none>)..."
# Get all images with a valid repository and tag
IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>:")

if [ -z "$IMAGES" ]; then
    echo "Error: No valid local images found. Exiting."
    exit 1
fi

echo -e "\nFound the following images to be saved:"
echo "$IMAGES" | sed 's/^/  - /'

echo -e "\nSaving all images to a compressed archive: $OUTPUT_FILE"
echo "This might take a while depending on the number and size of your images..."

# The 'docker save' command can take multiple image names.
# We pipe its output directly to gzip for compression.
docker save $IMAGES | gzip > "$OUTPUT_FILE"

echo -e "\n✔ Success!"
echo "Image archive created at: $PROJECT_ROOT/$OUTPUT_FILE"
echo ""
echo "To load these images on another machine, copy the archive and run:"
echo "  docker load -i $OUTPUT_FILE"

exit 0 