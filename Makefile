NAME = inception

all: $(NAME)

$(NAME):
	@mkdir -p /home/atambo/data/mariadb
	@mkdir -p /home/atambo/data/wordpress
	docker compose -f srcs/docker-compose.yml up --build -d

build:
	docker compose -f srcs/docker-compose.yml build

up:
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

stop:
	docker compose -f srcs/docker-compose.yml stop

start:
	docker compose -f srcs/docker-compose.yml start

clean:
	docker compose -f srcs/docker-compose.yml down --rmi all --volumes

fclean: clean
	@docker system prune -a --force
	@sudo rm -rf /home/atambo/data/*

re: fclean all

.PHONY: all build up down stop start clean fclean re
