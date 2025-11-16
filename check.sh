#!/bin/bash

# Script de verificação do projeto Inception
# Valida se tudo está configurado conforme o subject

echo "========================================="
echo "   INCEPTION - VALIDATION CHECKER"
echo "========================================="
echo ""

ERRORS=0
WARNINGS=0

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para marcar como OK
check_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

# Função para marcar erro
check_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

# Função para marcar warning
check_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

echo "1. Checking file structure..."
echo "─────────────────────────────"

# Verificar arquivos essenciais
[ -f "Makefile" ] && check_ok "Makefile exists" || check_error "Makefile missing"
[ -f "srcs/docker-compose.yml" ] && check_ok "docker-compose.yml exists" || check_error "docker-compose.yml missing"
[ -f "srcs/.env" ] && check_ok ".env file exists" || check_error ".env file missing"

# Verificar Dockerfiles
[ -f "srcs/requirements/nginx/Dockerfile" ] && check_ok "NGINX Dockerfile exists" || check_error "NGINX Dockerfile missing"
[ -f "srcs/requirements/wordpress/Dockerfile" ] && check_ok "WordPress Dockerfile exists" || check_error "WordPress Dockerfile missing"
[ -f "srcs/requirements/mariadb/Dockerfile" ] && check_ok "MariaDB Dockerfile exists" || check_error "MariaDB Dockerfile missing"

echo ""
echo "2. Checking Dockerfiles compliance..."
echo "─────────────────────────────────────"

# Verificar se não usa tag 'latest'
if ! grep -r "FROM.*:latest" srcs/requirements/*/Dockerfile 2>/dev/null; then
    check_ok "No 'latest' tag found in Dockerfiles"
else
    check_error "'latest' tag found in Dockerfiles"
fi

# Verificar se usa debian:bullseye
if grep -r "FROM debian:bullseye" srcs/requirements/*/Dockerfile | wc -l | grep -q "3"; then
    check_ok "All Dockerfiles use debian:bullseye"
else
    check_warning "Not all Dockerfiles use debian:bullseye"
fi

# Verificar hacky patches
if grep -rE "(tail -f|sleep infinity|while true)" srcs/requirements/*/tools/ 2>/dev/null; then
    check_error "Hacky patches found (tail -f, sleep infinity, while true)"
else
    check_ok "No hacky patches found"
fi

echo ""
echo "3. Checking docker-compose.yml..."
echo "─────────────────────────────────"

# Verificar network
if grep -q "inception_network" srcs/docker-compose.yml; then
    check_ok "Custom network configured"
else
    check_error "Custom network not found"
fi

# Verificar se não usa network: host ou links:
if grep -qE "(network_mode.*host|links:)" srcs/docker-compose.yml; then
    check_error "Forbidden: network: host or links: found"
else
    check_ok "No forbidden network configurations"
fi

# Verificar restart policies
RESTART_COUNT=$(grep -c "restart: always" srcs/docker-compose.yml)
if [ "$RESTART_COUNT" -eq 3 ]; then
    check_ok "All services have restart: always"
else
    check_error "Not all services have restart policy (found $RESTART_COUNT, expected 3)"
fi

# Verificar volumes
if grep -q "mariadb_data" srcs/docker-compose.yml && grep -q "wordpress_data" srcs/docker-compose.yml; then
    check_ok "Named volumes configured"
else
    check_error "Named volumes not properly configured"
fi

# Verificar se volumes apontam para /home/login/data
if grep -q "/home/cadete/data" srcs/docker-compose.yml; then
    check_ok "Volumes point to /home/login/data"
else
    check_error "Volumes don't point to /home/login/data"
fi

echo ""
echo "4. Checking .env file..."
echo "────────────────────────"

if [ -f "srcs/.env" ]; then
    # Verificar variáveis necessárias
    REQUIRED_VARS=("DOMAIN_NAME" "MYSQL_DATABASE" "MYSQL_USER" "MYSQL_PASSWORD" 
                   "MYSQL_ROOT_PASSWORD" "WP_ADMIN_USER" "WP_ADMIN_PASSWORD" 
                   "WP_USER" "WP_USER_PASSWORD")
    
    for var in "${REQUIRED_VARS[@]}"; do
        if grep -q "^${var}=" srcs/.env; then
            check_ok "$var is set"
        else
            check_error "$var is missing"
        fi
    done
    
    # Verificar se admin username não contém 'admin'
    ADMIN_USER=$(grep "^WP_ADMIN_USER=" srcs/.env | cut -d'=' -f2)
    if echo "$ADMIN_USER" | grep -iqE "(admin|administrator)"; then
        check_error "WP_ADMIN_USER contains 'admin' or 'administrator'"
    else
        check_ok "WP_ADMIN_USER doesn't contain forbidden words"
    fi
    
    # Verificar domain name
    DOMAIN=$(grep "^DOMAIN_NAME=" srcs/.env | cut -d'=' -f2)
    if echo "$DOMAIN" | grep -q "\.42\.fr"; then
        check_ok "DOMAIN_NAME follows login.42.fr format"
    else
        check_warning "DOMAIN_NAME doesn't follow login.42.fr format"
    fi
fi

echo ""
echo "5. Checking NGINX configuration..."
echo "──────────────────────────────────"

if [ -f "srcs/requirements/nginx/conf/nginx.conf" ]; then
    # Verificar TLS
    if grep -qE "ssl_protocols.*TLSv1\.[23]" srcs/requirements/nginx/conf/nginx.conf; then
        check_ok "TLSv1.2/TLSv1.3 configured"
    else
        check_error "TLSv1.2/TLSv1.3 not properly configured"
    fi
    
    # Verificar porta 443
    if grep -q "listen 443" srcs/requirements/nginx/conf/nginx.conf; then
        check_ok "NGINX listens on port 443"
    else
        check_error "NGINX not listening on port 443"
    fi
fi

echo ""
echo "6. Checking directory structure..."
echo "──────────────────────────────────"

if [ -d "/home/cadete/data" ]; then
    check_ok "Data directory exists"
    
    if [ -d "/home/cadete/data/mariadb" ]; then
        check_ok "MariaDB data directory exists"
    else
        check_warning "MariaDB data directory doesn't exist (will be created on first run)"
    fi
    
    if [ -d "/home/cadete/data/wordpress" ]; then
        check_ok "WordPress data directory exists"
    else
        check_warning "WordPress data directory doesn't exist (will be created on first run)"
    fi
else
    check_warning "Data directory doesn't exist (run 'make setup')"
fi

echo ""
echo "7. Checking /etc/hosts..."
echo "─────────────────────────"

if grep -q "fcaldas-.42.fr" /etc/hosts 2>/dev/null; then
    check_ok "Domain configured in /etc/hosts"
else
    check_warning "Domain not in /etc/hosts (you need to add it)"
    echo "          Run: sudo sh -c 'echo \"127.0.0.1 fcaldas-.42.fr\" >> /etc/hosts'"
fi

echo ""
echo "========================================="
echo "   VALIDATION SUMMARY"
echo "========================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Perfect! All checks passed!${NC}"
    echo "  Your project is ready for evaluation!"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Good, but with warnings${NC}"
    echo "  Errors: $ERRORS"
    echo "  Warnings: $WARNINGS"
    echo "  Please check the warnings above."
    exit 0
else
    echo -e "${RED}✗ Issues found!${NC}"
    echo "  Errors: $ERRORS"
    echo "  Warnings: $WARNINGS"
    echo "  Please fix the errors above before proceeding."
    exit 1
fi
