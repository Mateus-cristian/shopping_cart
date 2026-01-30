# Shopping Cart API

## Historia
Este projeto nasceu como base para uma evolucao futura de carrinho: simples hoje, mas pronto para suportar camadas mais inteligentes de regra e experiencia. A ideia e ter uma fundacao solida, com controle de interacoes, abandono e regras consistentes, antes de evoluir para funcionalidades mais complexas.

## Visao geral
API em Ruby on Rails para gerenciamento de carrinho de compras e produtos. Inclui:
- operacoes do carrinho (criar, adicionar item, remover item, visualizar)
- controle de abandono com job periodico
- documentacao Swagger/Rswag
- setup com Docker Compose

## Versoes
- Ruby: 3.3.1
- Rails: 7.1.3.2
- Node.js: 18.20.3
- PostgreSQL: 16

## Funcionalidades principais
- Criar carrinho e adicionar o primeiro item
- Adicionar ou atualizar itens no carrinho
- Remover itens do carrinho
- Retornar estado atual do carrinho
- Marcar carrinhos inativos como abandonados e remover antigos
- Documentacao de API em Swagger

## Endpoints principais
- `GET /cart` - retorna o carrinho atual (404 se inexistente)
- `POST /cart` - cria carrinho e adiciona item (201)
- `POST /cart/add_item` - adiciona ou atualiza item (404 se carrinho inexistente)
- `DELETE /cart/:product_id` - remove item do carrinho (404 se carrinho inexistente)
- `GET /products` - lista produtos
- `POST /products` - cria produto
- `PATCH /products/:id` - atualiza produto
- `DELETE /products/:id` - remove produto

## Como funciona por dentro
### Servicos
- `Carts::AddItemService` - adiciona item e atualiza total + ultima interacao
- `Carts::UpdateItemService` - atualiza/insere item e recalcula total
- `Carts::RemoveItemService` - remove item e recalcula total

### Job de abandono
- `AbandonedCartsJob` roda periodicamente para:
  - marcar carrinhos inativos como abandonados
  - remover carrinhos abandonados antigos

## Setup rapido
### Permissoes do Swagger
Apos clonar o projeto, rode:

```sh
./scripts/setup_permissions.sh
```

Se necessario, rode com sudo:

```sh
sudo ./scripts/setup_permissions.sh
```

## Rodando com Docker
Subir os containers (sem o container de teste):

```sh
bundle exec rake docker:up
```

Ou diretamente via Docker Compose:

```sh
docker compose up -d db redis api sidekiq
```

## Rodando testes
### Local

```sh
bundle exec rspec
```

### Em container isolado

```sh
bundle exec rake test:docker
```

## Documentacao da API
A documentacao Swagger/Rswag fica disponivel em:
- UI: `/api-docs`
- YAML: `swagger/v1/swagger.yaml`

## Estrutura do projeto
- `app/controllers` - endpoints da API
- `app/services` - regras de negocio do carrinho
- `app/jobs` - job de abandono
- `spec` - testes
- `swagger` - definicoes da API
- `husky` - hooks de git para garantir padroes antes de commits

## Roadmap
Este projeto e a base para a evolucao do carrinho. As proximas etapas incluem promocoes, cupons, estoque em tempo real e personalizacao por usuario.
