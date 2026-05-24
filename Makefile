NAME = inception
SECRETS_DIR := $(HOME)/.inception_secrets

# List of required secrets (must match those used in docker-compose.yml)
REQUIRED_SECRETS := db_root_password db_password wp_admin_password wp_user_password

# Check if Docker Swarm is active
check_swarm:
	@state=$$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null); \
	if [ "$$state" != "active" ]; then \
		echo "ERROR: Docker Swarm mode is not active. Current state: $$state"; \
		echo "Please run:  docker swarm init"; \
		exit 1; \
	fi

# Check if all required secrets exist in Swarm
check_secrets:
	@missing=""; \
	for secret in $(REQUIRED_SECRETS); do \
		if ! docker secret ls --format "{{.Name}}" | grep -qx "$$secret"; then \
			missing="$$missing $$secret"; \
		fi; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "ERROR: Missing Docker secrets:$$missing"; \
		echo "Please run:  make secrets"; \
		exit 1; \
	fi

# Build images using standard compose
build_images:
	docker compose -f srcs/docker-compose.yml build

# Deploy the stack – requires swarm active and all secrets present
deploy: check_swarm check_secrets build_images
	mkdir -p /home/atambo/data/mariadb /home/atambo/data/wordpress
	docker stack deploy -c srcs/docker-compose.yml $(NAME)

# Convenience targets
all: deploy

up: deploy

down:
	docker stack rm $(NAME)

stop: down

start: deploy

# Clean everything: remove stack, prune volumes, delete data
clean: down
	docker system prune -a --volumes --force

fclean: clean
	docker run --rm -v /home/atambo/data:/data alpine:3.19 rm -rf /data/mariadb /data/wordpress

re: fclean all

# Create secrets interactively (idempotent, skips existing)
secrets:
	@mkdir -p $(SECRETS_DIR)
	@chmod 700 $(SECRETS_DIR)
	@for secret in $(REQUIRED_SECRETS); do \
		if docker secret ls --format "{{.Name}}" | grep -qx "$$secret"; then \
			echo "Secret $$secret already exists. Skipping."; \
		else \
			echo -n "Enter password for $$secret: "; \
			stty -echo; read pass; stty echo; echo; \
			echo "$$pass" > $(SECRETS_DIR)/$$secret.txt; \
			chmod 600 $(SECRETS_DIR)/$$secret.txt; \
			docker secret create $$secret $(SECRETS_DIR)/$$secret.txt > /dev/null; \
			echo "Created secret $$secret."; \
		fi; \
	done
	@echo "All required secrets are ready."

.PHONY: all check_swarm check_secrets build_images deploy up down stop start clean fclean re secrets