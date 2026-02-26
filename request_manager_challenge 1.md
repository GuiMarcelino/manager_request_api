# Desafio Técnico — Backend Ruby on Rails

## Sobre o Desafio

Você irá implementar um mini sistema de gerenciamento de solicitações em Ruby on Rails.
O objetivo é avaliar como você estrutura um projeto do zero, toma decisões de arquitetura
e escreve código de qualidade com testes.

**Prazo**: 3 dias úteis a partir do recebimento deste documento.
**Entrega**: Repositório GitHub público (ou privado com acesso concedido).
**Duração estimada**: 4–6 horas de implementação real.

---

## Contexto de Negócio

Uma empresa precisa de um sistema interno onde colaboradores criam **solicitações**
(_requests_), que passam por um fluxo de aprovação simples:

```
draft → pending_approval → approved
                        ↘ rejected
```

Cada solicitação pertence a uma conta (`Account`), tem um autor (`User`),
pode ter comentários e uma categoria.

---

## Parte 1 — Modelagem e Setup

### Entidades

| Modelo | Campos |
|--------|--------|
| `Account` | `id`, `name`, `cnpj:string`, `active:boolean` |
| `User` | `id`, `account_id`, `name`, `email`, `role:enum[viewer, editor, admin]` |
| `Category` | `id`, `account_id`, `name`, `active:boolean` |
| `Request` | `id`, `account_id`, `user_id`, `category_id`, `title`, `description`, `status:enum[draft, pending_approval, approved, rejected]`, `rejected_reason:text`, `submitted_at:datetime`, `decided_at:datetime` |
| `Comment` | `id`, `account_id`, `request_id`, `user_id`, `body:text` |

### Requisitos de modelo

- Associações com `inverse_of`
- Validações de presença nos campos obrigatórios
- Enum com prefixo no status (ex: `Request::STATUSES`)
- Scopes:
  - `Request.pending` — filtra por `status: :pending_approval`
  - `Request.by_account(account)` — filtra por account
  - `Comment.active` — apenas comentários não removidos (você decide a definição)

---

## Parte 2 — Service Layer (Core da Avaliação)

Implemente os seguintes services seguindo o padrão `ApplicationService`:

```
app/services/
  request_manager/
    request_creator.rb      # Cria solicitação no status :draft
    request_submitter.rb    # draft → pending_approval (valida campos, seta submitted_at)
    request_approver.rb     # pending_approval → approved (só admin pode)
    request_rejector.rb     # pending_approval → rejected (exige rejected_reason)
    request_lister.rb       # Filtra por account + status + category (opcional)
  comment_manager/
    comment_creator.rb      # Cria comentário numa solicitação
    comment_destructor.rb   # Remove comentário (só o autor ou admin)
```

### ApplicationService base

Você deve implementar (ou pode usar uma gem equivalente):

```ruby
# frozen_string_literal: true

# Base class for all service objects in the application.
class ApplicationService
  def self.call(params = {})
    new(params).call
  end

  private

  def service_result(success:, payload: nil, errors: nil)
    OpenStruct.new(success?: success, payload: payload, errors: errors)
  end

  def not_found_error(entity)
    service_result(success: false, errors: { message: "#{entity} not found", code: 404 })
  end

  def missing_service_parameter(param)
    service_result(success: false, errors: { message: "Missing required param: #{param}", code: 422 })
  end
end
```

### Padrão obrigatório para todos os services

```ruby
# frozen_string_literal: true

module RequestManager
  # Service responsible for submitting a draft request for approval.
  class RequestSubmitter < ApplicationService
    def initialize(params)
      @account = params.fetch(:account)
      @user    = params.fetch(:user)
      @id      = params.fetch(:id)
    end

    def call
      # max 20 linhas, guard clauses, sem trailing comma
    end

    private

    # métodos auxiliares extraídos aqui
  end
end
```

### Regras de negócio

| Service | Regras |
|---------|--------|
| `RequestCreator` | Cria no status `:draft`; associa ao `user` e `account` passados |
| `RequestSubmitter` | Só funciona se status for `:draft`; seta `submitted_at`; retorna erro 422 se status inválido |
| `RequestApprover` | Só `admin` pode aprovar; seta `decided_at`; retorna erro 403 se sem permissão |
| `RequestRejector` | Requer `rejected_reason` não vazio; seta `decided_at`; retorna erro 422 se razão ausente |
| `CommentCreator` | Associa ao `request`, `user` e `account`; valida que o request pertence à account |
| `CommentDestructor` | Só o autor ou `admin` pode remover; retorna erro 403 se sem permissão |

---

## Parte 3 — API

Escolha **uma** das opções abaixo e justifique no README.

### Opção A — GraphQL (preferencial)

- Schema com tipos `Query` e `Mutation`
- Resolvers finos (≤5 linhas): delegam para services
- Types: `RequestType`, `CommentType`, `UserType`
- Mutations: `CreateRequest`, `SubmitRequest`, `ApproveRequest`, `RejectRequest`, `CreateComment`, `DestroyComment`
- Query: `listRequests(status: String, categoryId: ID)`

Exemplo de resolver fino:

```ruby
# frozen_string_literal: true

module Mutations
  # Mutation to submit a draft request for approval.
  class SubmitRequest < BaseMutation
    argument :id, ID, required: true

    field :request, Types::RequestType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      result = RequestManager::RequestSubmitter.call(
        account: context[:current_account],
        user: context[:current_user],
        id: id
      )
      result.success? ? { request: result.payload, errors: [] } : { request: nil, errors: [result.errors[:message]] }
    end
  end
end
```

### Opção B — REST

- `RequestsController`: `index`, `create`, `show`, `submit`, `approve`, `reject`
- `CommentsController`: `create`, `destroy`
- Respostas JSON padronizadas:
  ```json
  { "data": { ... }, "errors": [] }
  ```
- Autenticação simplificada: passe `user_id` e `account_id` no header ou como parâmetro
  (não precisa de JWT real, mas documente a decisão)

---

## Parte 4 — Testes RSpec (Obrigatório)

### Estrutura mínima exigida

```
spec/
  models/
    request_spec.rb
    comment_spec.rb
  services/
    request_manager/
      request_creator_spec.rb
      request_submitter_spec.rb
      request_approver_spec.rb
      request_rejector_spec.rb
    comment_manager/
      comment_creator_spec.rb
      comment_destructor_spec.rb
  factories/
    accounts.rb
    users.rb
    categories.rb
    requests.rb
    comments.rb
```

### Padrão de spec esperado

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestManager::RequestSubmitter, type: :service do
  let(:account) { create(:account) }
  let(:user)    { create(:user, account: account) }
  let(:request) { create(:request, account: account, user: user, status: :draft) }

  describe '#call' do
    subject { described_class.new(account: account, user: user, id: request.id).call }

    context 'when request is in draft status' do
      it { is_expected.to be_success }

      it 'transitions to pending_approval' do
        expect { subject }.to change { request.reload.status }.from('draft').to('pending_approval')
      end

      it 'sets submitted_at' do
        expect { subject }.to change { request.reload.submitted_at }.from(nil)
      end
    end

    context 'when request is already submitted' do
      before { request.update!(status: :pending_approval) }

      it { is_expected.not_to be_success }

      it 'returns a 422 error code' do
        expect(subject.errors[:code]).to eq 422
      end
    end

    context 'when request does not belong to account' do
      let(:other_account) { create(:account) }

      it 'returns not found error' do
        result = described_class.new(account: other_account, user: user, id: request.id).call
        expect(result.errors[:code]).to eq 404
      end
    end
  end
end
```

### O que cobrimos ao avaliar os testes

- Cenários de sucesso e cenários de erro para cada service
- Testes de modelo: associações, validações, scopes
- Uso de FactoryBot (sem fixtures)
- Legibilidade: contextos descritivos, nomes de exemplo claros

---

## Requisitos de Qualidade (Obrigatórios)

- `# frozen_string_literal: true` em todos os arquivos Ruby
- RuboCop configurado e passando — use o `.rubocop.yml` fornecido como base
- Sem trailing comma no último item de arrays/hashes/argumentos
- Métodos com no máximo 20 linhas
- Guard clauses no lugar de `if/else` aninhados
- Factories com `Faker` para dados realistas
- `README.md` com:
  - Instruções de setup (`bundle install`, `rails db:setup`)
  - Como rodar os testes (`bundle exec rspec`)
  - Decisões técnicas relevantes
  - O que faria diferente com mais tempo

---

## Bônus

Estes itens não são obrigatórios, mas pesam positivamente:

- **CanCanCan**: `RequestPolicy` com permissões por role para usuários
  - `admin` pode tudo
  - `editor` pode criar, submeter e comentar
  - `viewer` só lê
- **DataLoader** (se GraphQL): evitar N+1 em queries com associações
- **SimpleCov**: cobertura acima de 90%
- **Scope `accessible_by`**: integrado com CanCanCan
- **Transactions**: ex. rejeição cria comentário automático atomicamente
- **AASM**: usar state machine gem para gerenciar transições de status das solicitações

---

## Critérios de Avaliação

| Critério | Peso | O que analisamos |
|---|---|---|
| Service Pattern | 30% | Segue ApplicationService? Extrai métodos privados? ≤20 linhas? Guard clauses? |
| Testes RSpec | 25% | Cobre cenários de sucesso E erro? Usa FactoryBot? Legível? |
| Modelagem ActiveRecord | 20% | Associações corretas? `inverse_of`? Scopes? Validações? |
| Qualidade de Código | 15% | RuboCop passa? Frozen literals? Sem trailing comma? Nomes claros? |
| API (GraphQL/REST) | 10% | Resolvers finos? Contrato bem definido? Resposta padronizada? |

---

## O que Valorizamos

- Código que comunica intenção claramente
- Testes que documentam o comportamento esperado
- Tomada de decisão explícita (documente suas escolhas no README)
- Simplicidade: não adicione o que não foi pedido

---

## Dúvidas?

Qualquer dúvida, responda o email com que recebeu este documento.

Boa sorte!
