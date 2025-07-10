#!/bin/bash
#
# This script provides a simple way to manage the Docker Compose environment.
# It should be run from the project's root directory.
# Example: ./scripts/manage.sh up

set -e

# --- Configuration ---
# Get the directory of this script to run commands from the project root.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"

# --- Functions ---

# Function to display usage information
usage() {
    echo "Usage: $0 {up|down|restart|clean|logs|ps}"
    echo "Commands:"
    echo "  up       - Start all services in detached mode."
    echo "  down     - Stop all services."
    echo "  restart  - Stop and then start all services."
    echo "  clean    - Stop and remove all containers, networks, and volumes."
    echo "  logs [service] - Follow logs. Optional: specify a service name."
    echo "  ps       - List all running containers for this project."
    exit 1
}

# --- Main Logic ---

# Navigate to the project root directory
cd "$PROJECT_ROOT"

# Check if a command was provided
if [ -z "$1" ]; then
    usage
fi

case "$1" in
    up)
        echo "Starting all services..."
        docker-compose up -d
        echo "All services started."
        docker-compose ps
        ;;
    down)
        echo "Stopping all services..."
        docker-compose down
        echo "All services stopped."
        ;;
    restart)
        echo "Restarting all services..."
        docker-compose down
        docker-compose up -d
        echo "All services restarted."
        docker-compose ps
        ;;
    clean)
        echo "WARNING: This will stop and REMOVE ALL containers, networks, and data volumes."
        read -p "Are you sure you want to continue? [y/N] " -r
        echo
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            echo "Cleaning up the environment..."
            docker-compose down --volumes --remove-orphans
            echo "Environment cleaned successfully."
        else
            echo "Cleanup cancelled."
        fi
        ;;
    logs)
        shift # Remove the 'logs' argument
        echo "Following logs... (Press Ctrl+C to stop)"
        docker-compose logs -f "$@"
        ;;
    ps)
        docker-compose ps
        ;;
    *)
        echo "Error: Unknown command '$1'"
        usage
        ;;
esac

exit 0 