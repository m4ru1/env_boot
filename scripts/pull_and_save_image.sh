 #!/bin/bash
#
# This script pulls one or more specified Docker images and saves them
# into a single compressed tarball.
#
# Usage:
#   ./scripts/pull_and_save_image.sh <image1> [image2...]
#
# Examples:
#   ./scripts/pull_and_save_image.sh redis:7.0
#   ./scripts/pull_and_save_image.sh redis mysql:8.0

set -e

# --- Functions ---
usage() {
    echo "Usage: $0 <image_name:tag> [another_image:tag...]"
    echo ""
    echo "Pulls specified Docker image(s) and saves them to a compressed archive."
    echo ""
    echo "Example (single image):"
    echo "  $0 redis:7.0"
    echo "  (This will create a file named 'redis-7.0.tar.gz')"
    echo ""
    echo "Example (multiple images):"
    echo "  $0 redis:7.0 mysql:8.0"
    echo "  (This will create a file named 'custom_images_YYYYMMDD.tar.gz')"
    exit 1
}

# --- Main Logic ---
if [ $# -eq 0 ]; then
    echo "Error: No image name provided."
    usage
fi

# Determine the output filename based on the number of images
if [ $# -eq 1 ]; then
    # Single image: create a specific filename
    # Replace slashes and colons with filesystem-safe characters
    OUTPUT_FILE=$(echo "$1" | sed 's/\//_/g' | sed 's/:/-/g').tar.gz
else
    # Multiple images: create a generic, dated filename
    DATE=$(date +%Y%m%d)
    OUTPUT_FILE="custom_images_${DATE}.tar.gz"
fi

echo "The following images will be pulled and saved:"
for IMG in "$@"; do
    echo "  - $IMG"
done
echo "Output file will be: $OUTPUT_FILE"
echo ""

# Pull all images first
echo "Pulling images..."
for IMG in "$@"; do
    echo "--> Pulling $IMG"
    docker pull "$IMG"
done

echo -e "\nAll images pulled successfully."
echo -e "Saving images to compressed archive: $OUTPUT_FILE"
echo "This may take a while..."

# Save all specified images to the archive and compress it
docker save "$@" | gzip > "$OUTPUT_FILE"

echo -e "\n✔ Success!"
echo "Image archive created at: $(pwd)/$OUTPUT_FILE"
echo ""
echo "To load these images on another machine, copy the archive and run:"
echo "  docker load -i $OUTPUT_FILE"

exit 0
