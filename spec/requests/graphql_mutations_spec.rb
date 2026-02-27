# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL API Mutations via HTTP', type: :request do
  let(:account) { create(:account, name: 'Conta Teste', cnpj: CNPJ.generate) }
  let(:user) { create(:user, account: account, name: 'Usuário Teste', email: 'teste@example.com', role: :admin) }
  let(:category) { create(:category, account: account, name: 'Categoria Teste') }

  before do
    Comment.delete_all
    Request.delete_all
    Category.delete_all
    User.delete_all
    Account.delete_all

    account
    user
    category
  end

  def graphql_request(query:, variables: {})
    headers = { 'X-User-Id' => user.id.to_s, 'X-Account-Id' => account.id.to_s }
    post '/graphql', params: { query: query, variables: variables }, as: :json, headers: headers
  end

  describe 'POST /graphql mutations' do
    describe 'createRequest' do
      let(:query) do
        <<~GQL
          mutation CreateRequest($title: String!, $categoryId: ID!, $description: String) {
            createRequest(title: $title, categoryId: $categoryId, description: $description) {
              request { id title status }
              errors
            }
          }
        GQL
      end

      it 'creates a request' do
        graphql_request(
          query: query,
          variables: { 'title' => 'Nova solicitação', 'categoryId' => category.id.to_s, 'description' => 'Desc' }
        )

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json.dig('data', 'createRequest', 'errors')).to eq([])
        expect(json.dig('data', 'createRequest', 'request', 'title')).to eq('Nova solicitação')
      end
    end

    describe 'submitRequest' do
      let!(:request) { create(:request, account: account, user: user, category: category, status: :draft) }
      let(:query) { "mutation { submitRequest(id: \"#{request.id}\") { request { status } errors } }" }

      it 'submits a request' do
        graphql_request(query: query)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig('data', 'submitRequest', 'request', 'status')).to eq('pending_approval')
      end
    end

    describe 'approveRequest' do
      let!(:request) do
        create(:request, account: account, user: user, category: category, status: :pending_approval)
      end
      let(:query) { "mutation { approveRequest(id: \"#{request.id}\") { request { status } errors } }" }

      it 'approves a request' do
        graphql_request(query: query)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig('data', 'approveRequest', 'request', 'status')).to eq('approved')
      end
    end

    describe 'rejectRequest' do
      let!(:request) do
        create(:request, account: account, user: user, category: category, status: :pending_approval)
      end
      let(:query) do
        "mutation { rejectRequest(id: \"#{request.id}\", rejectedReason: \"Motivo\") { request { status } errors } }"
      end

      it 'rejects a request' do
        graphql_request(query: query)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig('data', 'rejectRequest', 'request', 'status')).to eq('rejected')
      end
    end

    describe 'createComment' do
      let!(:request) { create(:request, account: account, user: user, category: category) }
      let(:query) do
        "mutation { createComment(requestId: \"#{request.id}\", body: \"Comentário\") { comment { body } errors } }"
      end

      it 'creates a comment' do
        graphql_request(query: query)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig('data', 'createComment', 'comment', 'body')).to eq('Comentário')
      end
    end

    describe 'destroyComment' do
      let(:comment_and_request) do
        req = create(:request, account: account, user: user, category: category)
        { comment: create(:comment, account: account, request: req, user: user, body: 'Comentário') }
      end

      let(:query) do
        "mutation { destroyComment(id: \"#{comment_and_request[:comment].id}\") { comment { id } errors } }"
      end

      it 'destroys a comment' do
        graphql_request(query: query)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig('data', 'destroyComment', 'comment', 'id'))
          .to eq(comment_and_request[:comment].id.to_s)
      end
    end
  end
end
