# 📝 ATUALIZAÇÃO: Configuração para VM da 42

## ✅ Alterações Realizadas

Todos os caminhos foram atualizados de `/home/fcaldas-/` para `/home/cadete/` para compatibilidade com a VM fornecida pela 42.

### 📂 Arquivos Atualizados:

1. **`srcs/docker-compose.yml`**
   - Volume mariadb_data: `/home/cadete/data/mariadb`
   - Volume wordpress_data: `/home/cadete/data/wordpress`

2. **`Makefile`**
   - DATA_DIR: `/home/cadete/data`

3. **`check.sh`**
   - Verificações de diretórios atualizadas para `/home/cadete/data`

4. **`VALIDATION.md`**
   - Todas as referências de documentação atualizadas

5. **`RECOVERY_NOTES.md`**
   - Todas as referências de documentação atualizadas

---

## 🚀 Como Usar na VM da 42

### 1️⃣ Na VM, adicione o domínio ao /etc/hosts:

```bash
sudo sh -c 'echo "127.0.0.1 fcaldas-.42.fr" >> /etc/hosts'
```

### 2️⃣ Execute o projeto:

```bash
make all
```

Isso irá:
- Criar os diretórios em `/home/cadete/data/mariadb` e `/home/cadete/data/wordpress`
- Build das imagens Docker
- Iniciar todos os containers

### 3️⃣ Acesse:

**https://fcaldas-.42.fr**

---

## ✅ Validação

Execute o script de validação para confirmar:

```bash
./check.sh
```

Todos os caminhos agora apontam corretamente para `/home/cadete/data/`.

---

## 📋 Estrutura de Diretórios na VM

```
/home/cadete/
└── data/
    ├── mariadb/       # Database persistente do MariaDB
    └── wordpress/     # Arquivos do WordPress
```

Os diretórios serão criados automaticamente pelo `make setup` ou `make all`.

---

## 🔄 Diferenças da VM Local vs VM da 42

| Item | VM Local | VM da 42 |
|------|----------|----------|
| Usuário | fcaldas- | cadete |
| Home | /home/fcaldas- | /home/cadete |
| Data Path | /home/fcaldas-/data | /home/cadete/data |
| Domínio | fcaldas-.42.fr | fcaldas-.42.fr (mesmo) |

**Nota**: O domínio permanece `fcaldas-.42.fr` porque é baseado no seu login da 42, não no usuário do sistema.

---

## ✅ Projeto Pronto para a VM da 42!

Todas as configurações foram ajustadas para funcionar corretamente na VM fornecida pela escola.
