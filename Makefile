NAME = inception
.DEFAULT_GOAL := build

# Colors
COLOR_RESET   := \033[0m
COLOR_RED     := \033[31m
COLOR_GREEN   := \033[32m
COLOR_YELLOW  := \033[33m
COLOR_MAGENTA := \033[35m
COLOR_CYAN    := \033[36m

# Build images
build:
	@printf "$(COLOR_CYAN)🏗️  Building Docker images...$(COLOR_RESET)\n"
	@docker compose -f srcs/docker-compose.yml build
	@if [ $$? -eq 0 ]; then \
		printf "$(COLOR_GREEN)✓ Build succeeded.$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_RED)✗ Build failed.$(COLOR_RESET)\n"; \
		exit 1; \
	fi

# Start stack
up:
	@printf "$(COLOR_CYAN)🚀 Starting the stack...$(COLOR_RESET)\n"
	@mkdir -p /home/atambo/data/mariadb /home/atambo/data/wordpress
	@docker compose -f srcs/docker-compose.yml up -d
	@if [ $$? -eq 0 ]; then \
		printf "$(COLOR_GREEN)✓ Stack started.$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_RED)✗ Start failed.$(COLOR_RESET)\n"; \
		exit 1; \
	fi
	@printf "$(COLOR_CYAN)⏳ Waiting for containers...$(COLOR_RESET)\n"
	@sleep 3
	@$(MAKE) status

# Stop
down:
	@printf "$(COLOR_CYAN)🛑 Stopping containers (keeping volumes)...$(COLOR_RESET)\n"
	@docker compose -f srcs/docker-compose.yml down
	@if [ $$? -eq 0 ]; then \
		printf "$(COLOR_GREEN)✓ Stopped.$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_RED)✗ Stop failed.$(COLOR_RESET)\n"; \
	fi

# Clean (remove Docker volumes)
clean: down
	@printf "$(COLOR_CYAN)🧹 Removing Docker volumes...$(COLOR_RESET)\n"
	@docker compose -f srcs/docker-compose.yml down -v
	@if [ $$? -eq 0 ]; then \
		printf "$(COLOR_GREEN)✓ Volumes removed.$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_RED)✗ Volume removal failed.$(COLOR_RESET)\n"; \
	fi

# Full cleanup
fclean: clean
	@printf "$(COLOR_CYAN)🔥 Performing full system cleanup...$(COLOR_RESET)\n"
	@docker system prune -a --volumes --force
	@if [ $$? -eq 0 ]; then \
		printf "$(COLOR_GREEN)✓ System pruned.$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_RED)✗ Prune failed.$(COLOR_RESET)\n"; \
	fi
	@printf "$(COLOR_CYAN)🗑️  Cleaning host data directories...$(COLOR_RESET)\n"
	@docker run --rm -v /home/atambo/data:/data alpine:3.19 sh -c "rm -rf /data/mariadb /data/wordpress && mkdir -p /data/mariadb /data/wordpress"
	@printf "$(COLOR_CYAN)🔐 Removing local secret files...$(COLOR_RESET)\n"
	@rm -rf $(HOME)/.inception_secrets
	@printf "$(COLOR_GREEN)✓ Full cleanup complete.$(COLOR_RESET)\n"
	@docker rmi -f alpine:3.19 2>/dev/null || true

# Rebuild from scratch
re: fclean up

# Status
status:
	@echo
	@printf "$(COLOR_MAGENTA)📊 Current stack status:$(COLOR_RESET)\n"
	@docker compose -f srcs/docker-compose.yml ps
	@echo
	@if docker compose -f srcs/docker-compose.yml ps --quiet 2>/dev/null | grep -q .; then \
		printf "$(COLOR_GREEN)🌟 All containers are running! Visit https://atambo.42.fr$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_YELLOW)No containers running. Run 'make up'.$(COLOR_RESET)\n"; \
	fi

# Logs
logs:
	@printf "$(COLOR_CYAN)📜 Following logs (Ctrl+C to stop)...$(COLOR_RESET)\n"
	@docker compose -f srcs/docker-compose.yml logs -f

.PHONY: build up down clean fclean re status logs