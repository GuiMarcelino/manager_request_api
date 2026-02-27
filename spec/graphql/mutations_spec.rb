# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/DescribeClass, RSpec/MultipleMemoizedHelpers -- integration tests, shared setup
RSpec.describe 'GraphQL Mutations' do
  let(:account) { create(:account, name: 'Conta Teste', cnpj: CNPJ.generate) }
  let(:user) { create(:user, account: account, name: 'Usuário Teste', email: 'teste@example.com', role: :admin) }
  let(:category) { create(:category, account: account, name: 'Categoria Teste') }
  let(:context) { { current_user: user, current_account: account } }

  def execute(query, variables = {})
    result = ManagerRequestApiSchema.execute(query, variables: variables, context: context)
    result.is_a?(Hash) ? result : result.to_h
  end

  describe 'createRequest' do
    let(:query) do
      <<~GQL
        mutation CreateRequest($title: String!, $categoryId: ID!, $description: String) {
          createRequest(title: $title, categoryId: $categoryId, description: $description) {
            request { id title description status }
            errors
          }
        }
      GQL
    end

    it 'creates a request' do
      result = execute(query, {
                         'title' => 'Nova solicitação',
                         'categoryId' => category.id.to_s,
                         'description' => 'Descrição opcional'
                       })

      expect(result['errors']).to be_blank
      expect(result.dig('data', 'createRequest', 'errors')).to eq([])
      expect(result.dig('data', 'createRequest', 'request', 'title')).to eq('Nova solicitação')
      expect(result.dig('data', 'createRequest', 'request', 'status')).to eq('draft')
    end

    context 'when category does not exist' do
      it 'returns error' do
        result = execute(query, {
                           'title' => 'Nova solicitação',
                           'categoryId' => '99999',
                           'description' => nil
                         })

        expect(result['errors']).to be_present
      end
    end

    context 'when title is blank' do
      it 'returns validation error' do
        result = execute(query, {
                           'title' => '',
                           'categoryId' => category.id.to_s,
                           'description' => nil
                         })

        expect(result['errors']).to be_present
      end
    end
  end

  # -- shared setup for mutation tests
  describe 'submitRequest' do
    let!(:request) do
      create(:request, account: account, user: user, category: category, status: :draft)
    end

    let(:query) do
      <<~GQL
        mutation SubmitRequest($id: ID!) {
          submitRequest(id: $id) {
            request { id status }
            errors
          }
        }
      GQL
    end

    it 'submits a request' do
      result = execute(query, { 'id' => request.id.to_s })

      expect(result['errors']).to be_blank
      expect(result.dig('data', 'submitRequest', 'errors')).to eq([])
      expect(result.dig('data', 'submitRequest', 'request', 'status')).to eq('pending_approval')
    end
  end

  describe 'approveRequest' do
    let!(:request) do
      create(:request, account: account, user: user, category: category, status: :pending_approval)
    end

    let(:query) do
      <<~GQL
        mutation ApproveRequest($id: ID!) {
          approveRequest(id: $id) {
            request { id status }
            errors
          }
        }
      GQL
    end

    it 'approves a request' do
      result = execute(query, { 'id' => request.id.to_s })

      expect(result['errors']).to be_blank
      expect(result.dig('data', 'approveRequest', 'errors')).to eq([])
      expect(result.dig('data', 'approveRequest', 'request', 'status')).to eq('approved')
    end
  end

  describe 'rejectRequest' do
    let!(:request) do
      create(:request, account: account, user: user, category: category, status: :pending_approval)
    end

    let(:query) do
      <<~GQL
        mutation RejectRequest($id: ID!, $rejectedReason: String!) {
          rejectRequest(id: $id, rejectedReason: $rejectedReason) {
            request { id status rejectedReason }
            errors
          }
        }
      GQL
    end

    it 'rejects a request' do
      result = execute(query, { 'id' => request.id.to_s, 'rejectedReason' => 'Motivo da rejeição' })

      expect(result['errors']).to be_blank
      expect(result.dig('data', 'rejectRequest', 'errors')).to eq([])
      expect(result.dig('data', 'rejectRequest', 'request', 'status')).to eq('rejected')
      expect(result.dig('data', 'rejectRequest', 'request', 'rejectedReason')).to eq('Motivo da rejeição')
    end
  end

  describe 'createComment' do
    let!(:request) do
      create(:request, account: account, user: user, category: category)
    end

    let(:query) do
      <<~GQL
        mutation CreateComment($requestId: ID!, $body: String!) {
          createComment(requestId: $requestId, body: $body) {
            comment { id body active }
            errors
          }
        }
      GQL
    end

    it 'creates a comment' do
      result = execute(query, { 'requestId' => request.id.to_s, 'body' => 'Comentário de teste' })

      expect(result['errors']).to be_blank
      expect(result.dig('data', 'createComment', 'errors')).to eq([])
      expect(result.dig('data', 'createComment', 'comment', 'body')).to eq('Comentário de teste')
      expect(result.dig('data', 'createComment', 'comment', 'active')).to be true
    end

    context 'when request does not exist' do
      it 'returns error' do
        result = execute(query, { 'requestId' => '99999', 'body' => 'Comentário' })

        expect(result['errors']).to be_present
      end
    end
  end

  describe 'destroyComment' do
    let!(:request) { create(:request, account: account, user: user, category: category) }
    let!(:comment) { create(:comment, account: account, request: request, user: user, body: 'Comentário') }

    let(:query) do
      <<~GQL
        mutation DestroyComment($id: ID!) {
          destroyComment(id: $id) {
            comment { id }
            errors
          }
        }
      GQL
    end

    it 'destroys a comment' do
      result = execute(query, { 'id' => comment.id.to_s })

      expect(result['errors']).to be_blank
      expect(result.dig('data', 'destroyComment', 'errors')).to eq([])
      expect(result.dig('data', 'destroyComment', 'comment', 'id')).to eq(comment.id.to_s)
    end
  end
end
# rubocop:enable RSpec/DescribeClass, RSpec/MultipleMemoizedHelpers
