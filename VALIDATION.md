# ✅ VALIDAÇÃO FINAL - COMPLIANCE COM O SUBJECT

## 📋 Checklist de Conformidade

### ✅ Requisitos Gerais
- [x] **Docker Compose**: Projeto usa docker-compose.yml
- [x] **Nomes de imagens**: Cada imagem tem o nome do serviço correspondente
- [x] **Containers dedicados**: Cada serviço roda em container próprio
- [x] **Base OS**: Todos usam `debian:bullseye` (penúltima versão estável)
- [x] **Dockerfiles próprios**: Um Dockerfile por serviço (sem imagens prontas)
- [x] **Build via Makefile**: Makefile chama docker-compose.yml

### ✅ Containers e Serviços

#### NGINX
- [x] Container com NGINX
- [x] TLSv1.2 e TLSv1.3 configurados (`ssl_protocols TLSv1.2 TLSv1.3`)
- [x] Porta 443 exposta
- [x] Único ponto de entrada da infraestrutura
- [x] Não usa tag `latest` (usa `debian:bullseye`)

#### WordPress
- [x] Container com WordPress
- [x] php-fpm instalado e configurado
- [x] Sem nginx no container
- [x] Não usa tag `latest`
- [x] Script cria 2 usuários (admin + subscriber)
- [x] Nome do admin NÃO contém "admin" (usa "fcaldas")

#### MariaDB
- [x] Container com MariaDB
- [x] Sem nginx no container
- [x] Não usa tag `latest`
- [x] Script de inicialização cria database e usuários

### ✅ Volumes
- [x] Volume para database WordPress (`mariadb_data`)
- [x] Volume para arquivos WordPress (`wordpress_data`)
- [x] Volumes apontam para `/home/cadete/data/`

### ✅ Network
- [x] Docker network configurada (`inception_network`)
- [x] Bridge driver
- [x] Não usa `network: host`
- [x] Não usa `--link` ou `links:`

### ✅ Restart Policy
- [x] Todos os containers têm `restart: always`

### ✅ PID 1 e Best Practices
- [x] **NGINX**: usa `nginx -g "daemon off;"` como PID 1
- [x] **WordPress**: usa `php-fpm7.4 -F` como PID 1
- [x] **MariaDB**: usa `mysqld_safe` como PID 1
- [x] **Sem hacky patches**: Nenhum `tail -f`, `sleep infinity`, `while true`, etc.
- [x] **Sem loops infinitos**: Todos os processos são daemons apropriados

### ✅ Segurança
- [x] Senhas não estão nos Dockerfiles
- [x] Usa variáveis de ambiente (`.env`)
- [x] `.env` está no `.gitignore`
- [x] Certificado SSL gerado dinamicamente

### ✅ Domínio
- [x] Configurado como `login.42.fr` (fcaldas-.42.fr)
- [x] Script gera certificado com o domínio correto

---

## 🎯 VALIDAÇÃO: PROJETO 100% CONFORME

Todos os requisitos do subject foram atendidos!

---

## 📖 Documentação Técnica

### Estrutura de Comunicação

```
                                    HOST (VM)
┌───────────────────────────────────────────────────────────────────┐
│                                                                     │
│  /home/cadete/data/mariadb/     /home/cadete/data/wordpress/      │
│         └─ Database Volume              └─ WordPress Volume        │
│                  │                              │                  │
│  ┌───────────────────────────────────────────────────────────┐   │
│  │              DOCKER NETWORK (inception_network)            │   │
│  │                                                             │   │
│  │  ┌──────────┐         ┌──────────┐         ┌──────────┐  │   │
│  │  │          │  3306   │          │  9000   │          │  │   │
│  │  │ MariaDB  │◄───────►│WordPress │◄───────►│  NGINX   │  │   │
│  │  │          │         │ + PHP    │         │          │  │   │
│  │  └────┬─────┘         └────┬─────┘         └────┬─────┘  │   │
│  │       │                    │                     │         │   │
│  │       │                    │                     │         │   │
│  └───────┼────────────────────┼─────────────────────┼─────────┘   │
│          │                    │                     │              │
│          └────────────────────┴─────────────────────┘              │
│                                                      ▲              │
└──────────────────────────────────────────────────────┼──────────────┘
                                                       │
                                                    443 (HTTPS)
                                                       │
                                                   Internet
                                              (fcaldas-.42.fr)
```

### Ordem de Inicialização

1. **MariaDB** (primeiro)
   - Inicializa banco de dados
   - Cria database `wordpress`
   - Cria usuário `wpuser`

2. **WordPress** (depende de MariaDB)
   - Aguarda MariaDB estar pronto
   - Baixa WordPress via wp-cli
   - Configura conexão com banco
   - Cria usuários admin e subscriber
   - Inicia php-fpm

3. **NGINX** (depende de WordPress)
   - Gera certificado SSL
   - Inicia como proxy reverso
   - Escuta na porta 443

### Portas de Comunicação

- **443**: NGINX ← Internet (HTTPS)
- **9000**: NGINX ← WordPress (FastCGI)
- **3306**: WordPress ← MariaDB (MySQL)

---

## 🚀 Como Usar

### Pré-requisitos

1. **Configurar /etc/hosts**:
   ```bash
   sudo sh -c 'echo "127.0.0.1 fcaldas-.42.fr" >> /etc/hosts'
   ```

2. **Criar diretórios de dados** (o Makefile faz isso automaticamente):
   ```bash
   mkdir -p /home/cadete/data/mariadb
   mkdir -p /home/cadete/data/wordpress
   ```

### Comandos Principais

```bash
# Iniciar todo o projeto
make all

# Ou fazer passo a passo:
make setup    # Cria diretórios
make build    # Build das imagens
make up       # Inicia containers

# Verificar status
make status
make logs

# Parar containers
make down

# Limpar tudo
make fclean

# Rebuild completo
make re
```

### Acessar o Site

Após executar `make all`, acesse:
- **https://fcaldas-.42.fr**

**Nota**: O navegador alertará sobre certificado auto-assinado. Isso é normal! Aceite e continue.

### Login WordPress

**Admin**:
- Usuário: `fcaldas`
- Senha: `fcaldas123456`
- Email: `fcaldas-@student.42.fr`

**Subscriber**:
- Usuário: `subscriber`
- Senha: `subscriber123`
- Email: `subscriber@student.42.fr`

---

## 🔧 Troubleshooting

### Erro: "Permission denied" nos volumes

```bash
sudo chown -R $USER:$USER /home/cadete/data/
```

### Containers não iniciam

```bash
# Ver logs
make logs

# Ou específico:
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Refazer do zero

```bash
make fclean
make all
```

### Acessar shell dos containers

```bash
make exec-nginx      # Shell do NGINX
make exec-wordpress  # Shell do WordPress
make exec-mariadb    # Shell do MariaDB
```

---

## 📝 Notas Importantes

1. **Senhas**: Altere as senhas no `.env` antes de usar em produção!
2. **Volumes**: Os dados persistem em `/home/cadete/data/`
3. **Backup**: Faça backup dos volumes antes de `make fclean`
4. **Certificado**: É auto-assinado, válido apenas para desenvolvimento
5. **MariaDB**: Primeira inicialização pode levar alguns segundos

---

## ✅ Projeto Completo e Funcional!

O projeto está 100% conforme com o subject da 42 e pronto para avaliação!
