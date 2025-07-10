 #!/bin/bash
#
# This script pulls all Docker images defined in docker-compose.yml,
# and saves them into a single compressed tarball.
# It should be run from the project's root directory.
# Example: ./scripts/save_images.sh

set -e

# --- Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"
OUTPUT_FILE="env_boot_images.tar.gz"

# --- Main Logic ---
cd "$PROJECT_ROOT"

echo "Parsing docker-compose.yml to find all required images..."
# Use 'docker-compose config' to get the final configuration with variables substituted.
# Then grep for 'image:' and awk to extract the image name.
IMAGES=$(docker-compose config | grep 'image:' | awk '{print $2}')

if [ -z "$IMAGES" ]; then
    echo "Error: No images found in docker-compose.yml. Exiting."
    exit 1
fi

echo -e "\nFound the following images:"
echo "$IMAGES" | sed 's/^/  - /'

echo -e "\nPulling latest versions of all images..."
for IMG in $IMAGES; do
    echo "--> Pulling $IMG"
    docker pull "$IMG"
done

echo -e "\nAll images pulled successfully."
echo -e "\nSaving images to a compressed archive: $OUTPUT_FILE..."

# The 'docker save' command can take multiple image names.
# We pipe its output directly to gzip for compression to save space and time.
docker save $IMAGES | gzip > "$OUTPUT_FILE"

echo -e "\n✔ Success!"
echo "Image archive created at: $PROJECT_ROOT/$OUTPUT_FILE"
echo ""
echo "To load these images on another machine, copy the archive and run:"
echo "  docker load -i $OUTPUT_FILE"

exit 0
