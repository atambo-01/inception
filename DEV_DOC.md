# Developer Documentation – Inception

### Setting Up the Environment from Scratch

### Prerequisites

- **Operating system**: Linux family
- **Docker** (version 20.10 or later) and **Docker Compose** (version 2.0 or later).  
  Install via your package manager or from [docker.com](https://docs.docker.com/engine/install/).
- The domain `atambo.42.fr` must resolve to your local machine.  
  Add this line to `/etc/hosts` (requires `sudo`):  
  `127.0.0.1 atambo.42.fr`

### Configuration Files

All configuration is kept in the `srcs/` directory.

- `srcs/.env` – non‑sensitive environment variables (ports, domain, Alpine version).  
  Edit this file to change the exposed HTTPS port or the domain name.
- `srcs/docker-compose.yml` – defines the three services, networks, volumes, and secrets.

### Secrets (Passwords)

Secrets are not stored in the repository. You must generate them before the first run.

1. Run the setup script:  
   `srcs/setup_secrets.sh`  
   This creates the directory `~/.inception_secrets/` and sets passwords for all required secrets.

2. (Optional) To change any password manually, edit the corresponding `.txt` file in `~/.inception_secrets/`.


## Building and Launching the Project

All common tasks are available through the `Makefile` at the project root.

### Build the Docker Images

make build


This builds three images from the Dockerfiles in:
- `srcs/requirements/mariadb/Dockerfile`
- `srcs/requirements/wordpress/Dockerfile`
- `srcs/requirements/nginx/Dockerfile`

Each image is tagged with its service name and version `1.0` (e.g., `mariadb:1.0`).  
The build uses the Alpine version defined in `.env`.

### Start the Stack

make up

This runs `docker-compose up -d` which:
- Creates the custom bridge network `inception`
- Creates the named volumes `mariadb_data` and `wordpress_data` (bound to `/home/atambo/data/`)
- Starts the containers in the order: MariaDB -> WordPress -> NGINX

### Open the Website in a Browser

make open

Waits 5 seconds and then opens a private browser window (Firefox or Chrome) at `https://atambo.42.fr:<NGINX_PORT>`.

### Stop the Stack (Keep Data)

make down


Stops all containers and removes the network, but preserves volumes and secrets.

### Complete Cleanup

| Command | Effect |
|---------|--------|
| `make clean` | Stops containers and **deletes** both named volumes (erases all data). |
| `make fclean` | Also removes the Docker images (`mariadb:1.0`, `wordpress:1.0`, `nginx:1.0`). |
| `make xclean` | Additionally removes unused volumes, networks, and build cache. |
| `make re` | Runs `fclean`, then `build`, then `up` (full rebuild). |

## Managing Containers and Volumes

### Useful Docker Commands

| Action | Command |
|--------|---------|
| List running containers | `docker ps` |
| List all containers (including stopped) | `docker ps -a` |
| View logs of a service | `docker logs <service>` (e.g., `docker logs nginx`) |
| Follow logs in real time | `docker-compose logs -f` |
| Execute a command inside a container | `docker exec -it <service> sh` |
| Restart a single service | `docker-compose restart wordpress` |

### Volume Management

- List named volumes: `docker volume ls`
- Inspect a volume (shows mount point): `docker volume inspect mariadb_data`
- The actual data lives on the host at:  
  - MariaDB: `/home/atambo/data/mariadb`  
  - WordPress files: `/home/atambo/data/wordpress`

These host directories are bind-mounted into the containers using Docker's local volume driver with `type=none` and `o=bind`. This satisfies the subject requirement that named volumes store data under `/home/login/data`.

## Data Persistence

All data is save in the named volumes, even if you run `make down` or restart the machine, the data remains. Only `make clean` or manual deletion removes it. Additionaly we also have the secrets we setup earlier.

- **Database** – All MariaDB files are stored in the `mariadb_data` volume.
- **WordPress files** – The entire WordPress installation (including themes, plugins, uploads) is stored in the `wordpress_data` volume.
- **Secrets** – Stored on the host in `~/.inception_secrets/` and are never inside the built images.

## Checking the Health of Services

The `docker-compose.yml` defines healthchecks for MariaDB and WordPress. NGINX depends on WordPress being healthy. To see the current health status:

If a container is unhealthy, check its logs with `docker logs <service>`.
