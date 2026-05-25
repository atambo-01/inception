NAME = inception
SECRETS_DIR := $(HOME)/.inception_secrets
SECRET_FILES := db_root_password.txt db_password.txt wp_admin_password.txt wp_user_password.txt

# Create secret files if they don't exist (prompt user)
secrets:
	@mkdir -p $(SECRETS_DIR)
	@chmod 700 $(SECRETS_DIR)
	@for file in $(SECRET_FILES); do \
		if [ ! -f "$(SECRETS_DIR)/$$file" ]; then \
			echo -n "Enter password for $$file: "; \
			stty -echo; read pass; stty echo; echo; \
			echo "$$pass" > "$(SECRETS_DIR)/$$file"; \
			chmod 600 "$(SECRETS_DIR)/$$file"; \
			echo "Created $(SECRETS_DIR)/$$file"; \
		else \
			echo "Secret file $(SECRETS_DIR)/$$file already exists, skipping."; \
		fi; \
	done

# Build images using docker compose
build:
	docker compose -f srcs/docker-compose.yml build

# Start the stack (creates directories, secrets if missing, builds, then up)
up: secrets build
	mkdir -p /home/atambo/data/mariadb /home/atambo/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d

# Stop containers but keep volumes
down:
	docker compose -f srcs/docker-compose.yml down

# Stop and remove containers, networks, volumes (Docker volumes only)
clean: down
	docker compose -f srcs/docker-compose.yml down -v

# Full clean: remove containers, volumes, images, and host data, and secret files
fclean: clean
	docker system prune -a --volumes --force
	docker run --rm -v /home/atambo/data:/data alpine:3.19 rm -rf /data/mariadb /data/wordpress
	rm -rf $(SECRETS_DIR)

# Rebuild everything from scratch
re: fclean up

# Status
ps:
	docker compose -f srcs/docker-compose.yml ps

logs:
	docker compose -f srcs/docker-compose.yml logs -f

.PHONY: secrets build up down clean fclean re ps logs