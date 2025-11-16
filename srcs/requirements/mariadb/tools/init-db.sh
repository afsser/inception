#!/bin/bash

# Script de inicialização do MariaDB
# Segue as best practices: não usa hacky patches, inicia o daemon corretamente

set -e

# Verifica se o diretório de dados já foi inicializado
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Inicia o MariaDB em background temporariamente para configuração
echo "Starting MariaDB temporarily for setup..."
mysqld_safe --datadir=/var/lib/mysql &
pid="$!"

# Aguarda o MariaDB estar pronto
echo "Waiting for MariaDB to be ready..."
for i in {30..0}; do
    if mysqladmin ping &>/dev/null; then
        break
    fi
    echo "MariaDB is unavailable - sleeping"
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "MariaDB did not start in time."
    exit 1
fi

echo "MariaDB is ready. Configuring database..."

# Configuração do banco de dados
mysql -u root << EOF
-- Configurar senha do root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Criar o database
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Criar usuário e dar permissões
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
EOF

echo "Database setup completed successfully!"

# Para o MariaDB temporário
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Aguarda o processo parar completamente
wait "$pid"

echo "Starting MariaDB in production mode..."
# Inicia o MariaDB como PID 1 (não é background, é o processo principal)
exec mysqld_safe --datadir=/var/lib/mysql
