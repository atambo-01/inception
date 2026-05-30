*This project has been created as part of the 42 curriculum by atambo.*

## Description 📝

**Inception** is a system administration project that sets up a small containerized infrastructure using Docker Compose. It runs three main services in separate containers:

- **NGINX** – the only entry point, serving HTTPS (TLSv1.2 or TLSv1.3) on port 443.
- **WordPress + PHP-FPM** – the CMS application, connected to MariaDB.
- **MariaDB** – the relational database for WordPress.

All services are built from Alpine Linux (penultimate stable version). Persistent data (database files and WordPress files) is stored in Docker named volumes bound to `/home/atambo/data/` on the host. Secrets (passwords) are managed via Docker secrets and environment variables, never hard‑coded in Dockerfiles.

### Main concepts

**Virtual Machines vs Docker** – Unlike VMs, Docker uses software-level virtualization: it only virtualizes part of the operating system to isolate processes while sharing the same hardware and kernel. This makes Docker much lighter and faster.

**Secrets vs Environment Variables** – Environment variables are easy to use but can be exposed via `docker inspect`, logs, or child processes. To avoid this with sensitive information, we use Docker secrets. Secrets encrypt sensitive data at rest and only mount them inside containers as temporary files. They are safer for production.

**Docker Network vs Host Network** – The host network attaches a container directly to the host’s network stack. A Docker network (bridge) creates a private internal network where containers can communicate by service name, and only exposed ports are accessible from the host.

**Docker Volumes vs Bind Mounts** – Bind mounts are simple folders that we bind to folders inside our containers. Named volumes are persistent data stores for containers, created and managed by Docker. In this project, named volumes are used with a bind option. We can verify they are named volumes by checking `docker volume ls` or by reading the `volumes:` section in `docker-compose.yml`.

## Instructions 🚀

### Prerequisites

- A Linux/macOS host with **Docker** and **Docker Compose** installed.
- The domain `atambo.42.fr` must point to your local machine (add `127.0.0.1 atambo.42.fr` to `/etc/hosts`).

### Build and Run

From the root of the repository (where the `Makefile` is located):

```bash
# First run this script set the passwords
srcs/setup_secrets.sh

# Then build, start, and open the project
make build up open

# Opens atambo.42.fr in a private browser window (Firefox/Chrome). Otherwise, u mustpaste the URL manually.

make build      # Builds all Docker images (mariadb, wordpress, nginx)
make up         # Starts the containers in detached mode
make down       # Stops and removes containers and network, but keeps volumes
make clean      # Stops containers and removes volumes (deletes all data)
make fclean     # Removes images as well
make status     # Shows container status
make xclean     # Removes everything including unused volumes/images
make open       # Waits 5 seconds and opens the website in a private browser window
make re         # Full rebuild (clean + build + up)
```
## Resources 📚

when the making of this project we used a variety of sorces:

- https://github.com/lhabacuc/guia_inception - Guide used for first steps

- https://docs.docker.com/ - Docker Documentation

- https://www.alpinelinux.org/ - Alpine Linux

- https://nginx.org/en/docs/ - NGINX SSL/TLS configuration

- https://docs.docker.com/ - WordPress official documentation

- https://mariadb.com/docs - MariaDB official documentation

### AI usage 🤖

This project was developed with the assistance of an AI (deepseek). The AI helped with:

    Understanding finer details of web server configuration and environment variable handling.

    Debugging database connection issues and troubleshooting runtime errors.

    Writing and refining automation scripts (Makefile rules, wait mechanisms).

    Suggesting improvements for project structure, health checks, and documentation.

    Reviewing and spell‑checking the README and other documentation files.

AI‑generated code was reviewed, tested, and studied before integration.


