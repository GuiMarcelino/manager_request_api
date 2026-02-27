# Manager Request API

API de gerenciamento de solicitações em Ruby on Rails.

## Setup

```bash
bundle install
rails db:setup
```

O `db:setup` cria o banco, carrega o schema e executa as seeds.

Para executar apenas as seeds (sem recriar o banco):

```bash
rails db:seed
```

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

### Headers de contexto

add mo headers:

| Header | Descrição |
|--------|-----------|
| `X-User-Id` | ID do usuário (define role e permissões via CanCanCan) |
| `X-Account-Id` | ID da conta |

**Exemplo (Postman)**:

```
Content-Type: application/json
X-User-Id: 1
X-Account-Id: 1
```

### Coleção Postman

O arquivo `Manager.postman_collection.json` na raiz do projeto contém uma coleção pronta para uso no Postman. Importe-o no Postman (File → Import) para testar as queries e mutations da API com exemplos configurados.

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

A query `listRequests` retorna requests com `user`, `category` e `comments`. Para evitar N+1 (uma query por request ao acessar essas associações), o schema usa **GraphQL::Dataloader** com `ActiveRecordAssociationSource`:

```ruby
# Types::BaseObject
def load_association(record, association, scope = nil)
  source = GraphQL::Dataloader::ActiveRecordAssociationSource
  context.dataloader.with(source, association, scope).load(record)
end
```

O `RequestType` chama `load_association(object, :user)`, `load_association(object, :category)` e `load_association(object, :comments, scope)` para cada associação. O DataLoader faz o batch automático dessas cargas, evitando N+1.

## O que faria diferente com mais tempo

- **Autenticação**: JWT ou similar
- **Graphql** melhorar a estrutura adicionando classe authorization com regras para cada role:
