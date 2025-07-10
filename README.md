# All-in-One Local Development Environment

This project provides a comprehensive, containerized local development environment using Docker Compose. It includes essential services like MySQL, Redis, and RocketMQ, pre-configured with high-availability features like master-slave replication and sentinel clusters. The environment is designed to be flexible, allowing you to run a simple standalone setup or a full, complex cluster with a single command.

## ✨ Features

- **MySQL 8.0**: Configured with Master-Slave replication.
- **Redis 7.x**: High-availability setup with a Sentinel cluster (1 Master, 2 Replicas, 3 Sentinels).
- **RocketMQ 5.x**: Includes a Nameserver and a Broker, with Access Control (ACL) enabled.
- **Flexible Deployment Modes**:
  - **Simple Mode**: Runs standalone instances of MySQL, Redis, and RocketMQ. Ideal for quick startup and basic development.
  - **Full Mode**: Activates all high-availability features, including MySQL replication and the full Redis Sentinel cluster.
- **Centralized Configuration**: All passwords, usernames, and keys are managed in a single `.env` file.
- **Powerful Tooling**: A suite of helper scripts to manage the environment's lifecycle, including startup, shutdown, cleanup, and image management.

##  prerequisites

Before you begin, ensure you have the following installed on your system:

- **Docker**: [Get Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: Usually included with Docker Desktop.
- **A Bash-compatible shell**: Required to run the helper scripts in the `scripts/` directory.
  - On **Windows**, you can use [Git Bash](https://git-scm.com/downloads) or [WSL](https://docs.microsoft.com/en-us/windows/wsl/install).
  - On **macOS** and **Linux**, the default terminal will work.

## 📂 Directory Structure

```
.
├── docker/                # Contains all configuration files for the services
│   ├── mysql/
│   ├── redis/
│   └── rocketmq/
├── scripts/               # Contains all helper scripts
│   ├── manage.sh
│   ├── pull_and_save_image.sh
│   ├── save_all_images.sh
│   └── save_images.sh
├── .env.example           # Example environment variables file
├── docker-compose.yml     # The main Docker Compose file defining all services
└── README.md              # This file
```

## 🚀 Getting Started

Follow these steps to get your environment up and running.

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd <repository-folder>
```

### 2. Create Your Environment File

The project uses a `.env` file to manage all credentials. You can create it by copying the provided template:

```bash
cp .env.example .env
```

You can now open the `.env` file and customize the passwords, usernames, ports, and keys to your liking.

### 3. Make Scripts Executable

(You only need to do this once)

```bash
chmod +x scripts/*.sh
```

### 4. Choose Your Deployment Mode

This environment can be launched in two modes using the `manage.sh` script.

#### Simple Mode (Default)

This mode starts a standalone instance of each service (1 MySQL, 1 Redis, 1 RocketMQ). It's lightweight and perfect for most daily development tasks.

```bash
./scripts/manage.sh up
```

#### Full Mode

This mode activates all high-availability features. It will start the MySQL slave, the Redis replicas, and the Redis sentinels in addition to the base services.

```bash
./scripts/manage.sh up full
```

To stop the environment, regardless of which mode you started, simply run:

```bash
./scripts/manage.sh down
```

## 🔌 Service Connection Details

Once the services are running, you can connect to them using the following details (defaults from `.env.example` shown):

| Service        | Host          | Port(s)                         | Username / AccessKey     | Password / SecretKey | Notes                                                              |
|----------------|---------------|---------------------------------|--------------------------|----------------------|--------------------------------------------------------------------|
| **MySQL Master** | `localhost`   | `3306`                          | `user`                   | `password`           | Your primary database for read/write.                              |
| **MySQL Slave**  | `localhost`   | `3307`                          | `user`                   | `password`           | Read-only replica. (Only available in **Full Mode**)               |
| **Redis**      | `localhost`   | `26379`, `26380`, `26381`        | (none)                   | `password`           | Connect to a Sentinel. Your client must specify the master name: `mymaster`. |
| **RocketMQ**   | `localhost`   | `9876` (NameServer)             | `rocketmq`               | `rocketmq2024`       | Use these credentials in your RocketMQ client.                     |

## 🧰 Scripts Toolbox

This project includes a set of powerful scripts in the `scripts/` directory to simplify management.

### `manage.sh`

The main script for controlling the environment's lifecycle.

| Command                            | Description                                                                 |
|------------------------------------|-----------------------------------------------------------------------------|
| `./scripts/manage.sh up`           | Starts the services in **Simple Mode**.                                     |
| `./scripts/manage.sh up full`      | Starts the services in **Full Mode**.                                       |
| `./scripts/manage.sh down`         | Stops all running services for this project.                                |
| `./scripts/manage.sh restart`      | Restarts the services in **Simple Mode**.                                   |
| `./scripts/manage.sh restart full` | Restarts the services in **Full Mode**.                                     |
| `./scripts/manage.sh logs [svc]`   | Tails the logs. Optionally specify a service name (e.g., `mysql-master`).   |
| `./scripts/manage.sh ps`           | Lists the running containers for the current mode.                          |
| `./scripts/manage.sh clean`        | **Destructive!** Stops and removes all containers, networks, and data volumes. |

### `save_images.sh`

Pulls and saves all Docker images required for the **full** environment into a `env_boot_images.tar.gz` file. Useful for transferring the environment to an offline machine.

```bash
./scripts/save_images.sh
```

### `save_all_images.sh`

Finds **all** Docker images on your local machine and saves them to a timestamped archive (e.g., `all_docker_images_HOSTNAME_YYYYMMDD.tar.gz`). Useful for full backups.

```bash
./scripts/save_all_images.sh
```

### `pull_and_save_image.sh`

A flexible utility to pull and save any specified Docker image(s).

```bash
# Save a single image (creates redis-7.0.tar.gz)
./scripts/pull_and_save_image.sh redis:7.0

# Save multiple images (creates custom_images_YYYYMMDD.tar.gz)
./scripts/pull_and_save_image.sh redis:7.0 mysql:8.0
```

---
Happy coding! 