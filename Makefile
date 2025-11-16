# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fcaldas- <fcaldas-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/11/16 00:00:00 by fcaldas-          #+#    #+#              #
#    Updated: 2025/11/16 00:00:00 by fcaldas-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# ========================================
# INCEPTION PROJECT MAKEFILE
# ========================================

# Directories
SRCS_DIR	= ./srcs
DATA_DIR	= /home/cadete/data
COMPOSE_FILE	= $(SRCS_DIR)/docker-compose.yml

# Colors for output
GREEN		= \033[0;32m
YELLOW		= \033[0;33m
RED		= \033[0;31m
RESET		= \033[0m

# ========================================
# MAIN TARGETS
# ========================================

all: setup up

# Setup: Create data directories if they don't exist
setup:
	@echo "$(YELLOW)Creating data directories...$(RESET)"
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@echo "$(GREEN)✓ Data directories created$(RESET)"

# Build: Build all Docker images
build: setup
	@echo "$(YELLOW)Building Docker images...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✓ Docker images built successfully$(RESET)"

# Up: Start all containers
up: setup
	@echo "$(YELLOW)Starting containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ Containers started successfully$(RESET)"
	@echo "$(GREEN)Access your site at: https://fcaldas-.42.fr$(RESET)"

# Down: Stop all containers
down:
	@echo "$(YELLOW)Stopping containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ Containers stopped$(RESET)"

# Restart: Restart all containers
restart: down up

# Logs: Show logs from all containers
logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

# Status: Show status of containers
status:
	@docker-compose -f $(COMPOSE_FILE) ps

# Clean: Stop containers and remove them (keeps volumes and images)
clean: down
	@echo "$(YELLOW)Removing containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) rm -f
	@echo "$(GREEN)✓ Containers removed$(RESET)"

# Fclean: Complete cleanup (removes containers, volumes, images, networks, and data)
fclean: down
	@echo "$(RED)Performing full cleanup...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	@docker system prune -af
	@sudo rm -rf $(DATA_DIR)/mariadb/*
	@sudo rm -rf $(DATA_DIR)/wordpress/*
	@echo "$(GREEN)✓ Full cleanup completed$(RESET)"

# Re: Full rebuild (fclean + all)
re: fclean all

# ========================================
# UTILITY TARGETS
# ========================================

# Exec into containers
exec-nginx:
	@docker exec -it nginx /bin/bash

exec-wordpress:
	@docker exec -it wordpress /bin/bash

exec-mariadb:
	@docker exec -it mariadb /bin/bash

# Check configuration
check:
	@echo "$(YELLOW)Checking configuration...$(RESET)"
	@echo "Data directories:"
	@ls -la $(DATA_DIR)
	@echo "\nDocker containers:"
	@docker-compose -f $(COMPOSE_FILE) ps
	@echo "\nDocker volumes:"
	@docker volume ls | grep inception || true
	@echo "\nDocker networks:"
	@docker network ls | grep inception || true

# Help: Display available commands
help:
	@echo "$(GREEN)========================================$(RESET)"
	@echo "$(GREEN)  INCEPTION PROJECT - MAKEFILE HELP   $(RESET)"
	@echo "$(GREEN)========================================$(RESET)"
	@echo ""
	@echo "$(YELLOW)Main targets:$(RESET)"
	@echo "  make all          - Setup and start all containers"
	@echo "  make build        - Build all Docker images"
	@echo "  make up           - Start all containers"
	@echo "  make down         - Stop all containers"
	@echo "  make restart      - Restart all containers"
	@echo "  make clean        - Stop and remove containers"
	@echo "  make fclean       - Complete cleanup (removes everything)"
	@echo "  make re           - Rebuild everything from scratch"
	@echo ""
	@echo "$(YELLOW)Utility targets:$(RESET)"
	@echo "  make logs         - Show container logs"
	@echo "  make status       - Show container status"
	@echo "  make check        - Check configuration and status"
	@echo "  make exec-nginx   - Access nginx container shell"
	@echo "  make exec-wordpress - Access wordpress container shell"
	@echo "  make exec-mariadb - Access mariadb container shell"
	@echo "  make help         - Show this help message"
	@echo ""

.PHONY: all setup build up down restart logs status clean fclean re \
	exec-nginx exec-wordpress exec-mariadb check help
