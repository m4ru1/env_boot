#!/bin/bash
#
# This script provides a simple way to manage the Docker Compose environment.
# It should be run from the project's root directory.
# Example (simple mode): ./scripts/manage.sh up
# Example (full mode):   ./scripts/manage.sh up full

set -e

# --- Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"

# --- Functions ---

# Function to display usage information
usage() {
    echo "Usage: $0 {up|down|restart|clean|logs|ps} [profile]"
    echo "Commands:"
    echo "  up [profile]     - Start services. Optional profile: 'full'."
    echo "  down             - Stop all services."
    echo "  restart [profile]- Restart services. Optional profile: 'full'."
    echo "  clean            - Stop and remove all containers, networks, and volumes."
    echo "  logs [service]   - Follow logs. Optional: specify a service name."
    echo "  ps [profile]     - List running containers. Optional profile: 'full'."
    echo ""
    echo "Examples:"
    echo "  ./scripts/manage.sh up        # Starts the simple environment"
    echo "  ./scripts/manage.sh up full   # Starts the full environment (with replication and sentinels)"
    exit 1
}

# --- Main Logic ---
cd "$PROJECT_ROOT"

if [ -z "$1" ]; then
    usage
fi

COMMAND=$1
PROFILE_ARG=""

# Check if a profile argument is provided for relevant commands
if [[ "$1" == "up" || "$1" == "restart" || "$1" == "ps" ]] && [ -n "$2" ]; then
    if [ "$2" == "full" ]; then
        PROFILE_ARG="--profile full"
        echo "Running with 'full' profile..."
    else
        echo "Warning: Unknown profile '$2'. Ignoring."
    fi
fi

case "$COMMAND" in
    up)
        echo "Starting services..."
        docker-compose $PROFILE_ARG up -d
        echo "Services started."
        docker-compose $PROFILE_ARG ps
        ;;
    down)
        echo "Stopping all services (including all profiles)..."
        # 'down' command does not need profile flag to stop all services
        docker-compose down
        echo "All services stopped."
        ;;
    restart)
        echo "Restarting services..."
        docker-compose $PROFILE_ARG down
        docker-compose $PROFILE_ARG up -d
        echo "Services restarted."
        docker-compose $PROFILE_ARG ps
        ;;
    clean)
        echo "WARNING: This will stop and REMOVE ALL containers, networks, and data volumes."
        read -p "Are you sure you want to continue? [y/N] " -r
        echo
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            echo "Cleaning up the environment..."
            # --all-profiles is not a valid flag, down --volumes cleans all
            docker-compose down --volumes --remove-orphans
            echo "Environment cleaned successfully."
        else
            echo "Cleanup cancelled."
        fi
        ;;
    logs)
        shift # Remove the 'logs' argument
        echo "Following logs... (Press Ctrl+C to stop)"
        docker-compose logs -f "${@:2}" # Pass remaining args
        ;;
    ps)
        docker-compose $PROFILE_ARG ps
        ;;
    *)
        echo "Error: Unknown command '$1'"
        usage
        ;;
esac

exit 0 