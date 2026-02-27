# Manager Request API

API de gerenciamento de solicitações em Ruby on Rails.

## Setup

```bash
bundle install
rails db:setup
```

O `db:setup` cria o banco, carrega o schema e executa as seeds.

Subir a aplicação:

```bash
bundle exec rails s -p 3000 -b 0.0.0.0
```

## Rodar os testes

```bash
bundle exec rspec
```

## Rodar com Docker

```bash
docker compose up -d --build
```

Ou, se a imagem já estiver construída:

```bash
docker compose up -d
```

Entrar no container da aplicação:

```bash
docker compose exec app bash
```

## API GraphQL

A API segue a **Opção A** do desafio.

### Endpoint

- **POST** `/graphql` — corpo: `{ "query": "...", "variables": { ... }, "operationName": "..." }` (opcional)

## Decisões técnicas relevantes

### Scopable no GraphQL

O concern `Queries::Concerns::Scopable` foi adotado para aplicar filtros de forma genérica nas queries,Em vez de repetir lógica de filtro em cada resolver, o Scopable:

- Recebe o objeto `filter` e o `scope` da relação
- Itera sobre as chaves do filter (ex.: `account_id`, `status`, `category_id`)
- Para cada chave, chama o scope correspondente no model (`by_account_id`, `by_status`, `by_category_id`)
- Mantém a regra de filtro nos scopes do model, e o GraphQL apenas delega

Assim, novos filtros exigem apenas: (1) argumento no Filter input, (2) scope no model. O resolver não precisa de código extra.

### Filtro `active` em Comments

O campo `comments` em `RequestType` aceita um argumento `filter: CommentFilter` com `active: Boolean`. A definição de "comentário ativo" é: `active: true` = não removido, `active: false`

### Evitar N+1 em listRequests

A query `listRequests` retorna requests com `user`, `category` e `comments`. Para evitar N+1 (uma query por request ao acessar essas associações), o resolver usa `includes` do ActiveRecord:

```ruby
scope.includes(:user, :category, :comments)
```

Assim, user, category e comments são carregados em batch na mesma query (ou em poucas queries adicionais), em vez de uma query por request. O DataLoader está habilitado no schema (`use GraphQL::Dataloader`), mas não é usado; o `includes` já resolve o problema para o cenário atual.

## O que faria diferente com mais tempo

- **Autenticação**: JWT ou similar
- **Graphql** melhorar a estrutura adicionando classe authorization com regras para cada role:
- **Schema introspection export**: gerar JSON do schema (como `octopus_core_printed_schema.json`) para documentação
