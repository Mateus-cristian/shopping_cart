# Setup rápido para evitar erros de permissão

Após clonar o projeto, rode o comando abaixo para garantir que a pasta swagger tenha as permissões corretas:

```sh
./scripts/setup_permissions.sh
```

Isso evita erros ao gerar a documentação Swagger com o Docker.

Se necessário, rode com sudo:

```sh
sudo ./scripts/setup_permissions.sh
```

---
