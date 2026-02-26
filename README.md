# Manager Request API

API de gerenciamento de solicitações em Ruby on Rails.

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

A API segue a **Opção A** do desafio: GraphQL com resolvers finos que delegam aos services.

### Endpoint

- **POST** `/graphql` — corpo: `{ "query": "...", "variables": { ... }, "operationName": "..." }` (opcional)

### Autenticação (simplificada)

Envie o usuário e a conta no header ou como parâmetro (não é necessário JWT):

- **X-Account-Id** ou `account_id`: ID da conta
- **X-User-Id** ou `user_id`: ID do usuário (deve pertencer à conta)

Sem esses valores, `listRequests` retorna lista vazia e as mutations falham por falta de context.

### Query

- **listRequests(status: String, categoryId: ID)** — lista solicitações da conta atual; filtros opcionais.

### Mutations

- **createRequest(title: String!, categoryId: ID!, description: String)**
- **submitRequest(id: ID!)**
- **approveRequest(id: ID!)**
- **rejectRequest(id: ID!, rejectedReason: String!)**
- **createComment(requestId: ID!, body: String!)**
- **destroyComment(id: ID!)**

Todas as mutations retornam `{ data: { mutationName: { request|comment, errors: [] } } }`. Em erro, `request`/`comment` vem `null` e `errors` traz as mensagens.
