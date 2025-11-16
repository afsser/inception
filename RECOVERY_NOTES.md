# Inception Project - Configuração Recuperada

## ✅ Arquivo .env Criado!

Criei o arquivo `.env` em `/srcs/.env` com todas as variáveis necessárias baseando-me na análise do código.

### 📋 Variáveis Configuradas:

#### 🌐 Domínio e SSL
- **DOMAIN_NAME**: fcaldas-.42.fr
- **CERT_COUNTRY**: BR
- **CERT_STATE**: Sao Paulo
- **CERT_CITY**: Sao Paulo
- **CERT_ORG**: 42 School
- **CERT_OU**: fcaldas-

#### 🗄️ MySQL/MariaDB
- **MYSQL_DATABASE**: wordpress
- **MYSQL_USER**: wpuser
- **MYSQL_PASSWORD**: wppassword123
- **MYSQL_ROOT_PASSWORD**: rootpassword123

#### 👤 WordPress Admin
- **WP_TITLE**: Inception Project
- **WP_ADMIN_USER**: fcaldas (não contém "admin" - seguindo as regras)
- **WP_ADMIN_PASSWORD**: fcaldas123456
- **WP_ADMIN_EMAIL**: fcaldas-@student.42.fr

#### 👥 WordPress User Regular
- **WP_USER**: subscriber
- **WP_USER_EMAIL**: subscriber@student.42.fr
- **WP_USER_PASSWORD**: subscriber123

---

## ⚠️ Pontos de Atenção:

### 1. **Altere as Senhas!**
As senhas no arquivo são exemplos. Por segurança, altere-as para senhas mais fortes.

### 2. **Configure o /etc/hosts**
Adicione ao seu arquivo `/etc/hosts`:
```
127.0.0.1    fcaldas-.42.fr
```

### 3. **MariaDB precisa de script de inicialização**
O container MariaDB está incompleto. Ele precisa:
- Variáveis de ambiente no docker-compose.yml
- Script de inicialização do banco de dados
- Volume para persistência dos dados

### 4. **Volumes estão faltando**
O docker-compose.yml precisa definir volumes para:
- Banco de dados MariaDB: `/home/cadete/data/mariadb`
- Arquivos WordPress: `/home/cadete/data/wordpress`

### 5. **Arquivo .env.example criado**
Criei também um `.env.example` como template para referência futura.

---

## 🔧 Próximos Passos Recomendados:

1. **Revisar e ajustar senhas** no arquivo `.env`
2. **Completar o docker-compose.yml** com volumes e env_file para mariadb
3. **Criar script de inicialização do MariaDB** (`srcs/requirements/mariadb/tools/init-db.sh`)
4. **Criar diretórios de volumes**: 
   ```bash
   mkdir -p /home/cadete/data/mariadb
   mkdir -p /home/cadete/data/wordpress
   ```
5. **Configurar /etc/hosts** para resolver fcaldas-.42.fr
6. **Criar Makefile** (se necessário) para facilitar build e deploy

Quer que eu ajude a completar alguma dessas tarefas?
