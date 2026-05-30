# User Documentation – Inception

## Services Provided

This project provides a fully functional WordPress website running inside Docker containers. The stack includes:

- **WordPress** – the main website where you can create posts, pages, and manage content.
- **MariaDB** – a database that stores all WordPress data (posts, users, settings).
- **NGINX** – a web server that handles HTTPS connections and serves the WordPress site.

Only the WordPress website is directly accessible to you. The database and web server run behind the scenes.

## Starting and Stopping the Project

From the root of the project directory (where the `Makefile` is located):

- **builds images**:  
  `make build or just make`  
  This creates all images for the services.

- **Start the stack** (if not already running):  
  `make up`  
  This launches all containers in the background.

  - **Open the url** (if u have firefox/chrome):  
  `make open`  
  This open the url in browser on private mode.
  If u dont have firefox/chrome u must manualy paste the url given after make up

- **Stop the stack** (keep data for next start):  
  `make down`  
  This stops and removes containers but preserves your database and WordPress files.

- **Restart after a crash** – Containers are configured with `restart: unless-stopped`, so they automatically restart if they crash.

## Accessing the Website and Administration Panel

### Website
Open your web browser and go to:  
`https://atambo.42.fr`

If you changed the port in the `.env` file, append `:<port_number>` (e.g., `https://atambo.42.fr:8443`).

### WordPress Admin Panel
Add `/wp-admin` to the website URL:  
`https://atambo.42.fr/wp-admin`

Login with the administrator credentials (see below).

## Credentials Management

All sensitive passwords are stored in **Docker secrets** – encrypted files on your host machine. They are never visible in the code.

### Locating Credentials
The secret files are located in `~/.inception_secrets/` (the `~` means your home directory). You will find:

- `db_root_password.txt` – MariaDB root password (not needed for normal use)
- `db_password.txt` – password for the WordPress database user
- `wp_admin_password.txt` – password for the WordPress admin user
- `wp_user_password.txt` – password for the second WordPress user (editor)

### Managing Credentials
- **To view a password**: `cat ~/.inception_secrets/wp_admin_password.txt`
- **To change a password**: edit the corresponding `.txt` file, then restart the stack:  
  `make re up`  
  (For WordPress user passwords, you may also change them inside the WordPress admin panel.)

> ⚠️ Never commit these secret files to Git. They are ignored by `.gitignore`.

## Checking That Services Are Running Correctly

Run the following commands from the project root:

- `make status` – shows a quick overview of container health.
- `docker ps` – lists all running containers and their status.
- `docker logs nginx` – shows the last log messages from the web server.
- `docker logs wordpress` – shows WordPress/PHP-FPM logs.
- `docker logs mariadb` – shows database logs.

If a container is missing or shows `Exited`, run `make up` to restart the stack.