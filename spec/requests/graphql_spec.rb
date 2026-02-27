# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL API', type: :request do
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

  describe 'POST /graphql' do
    describe 'listRequests query' do
      let(:query) do
        <<~GQL
          query ListRequests($filter: RequestFilter!) {
            listRequests(filter: $filter) {
              id
              title
              description
              status
              user { id name }
              category { id name }
              comments(filter: { active: true }) { id body active }
            }
          }
        GQL
      end

      context 'when account has requests' do
        let(:request_with_comments) do
          req = create(:request, account: account, user: user, category: category, title: 'Solicitação de teste')
          {
            request: req,
            comments: {
              active: create(:comment, account: account, request: req, user: user, body: 'Ativo', active: true),
              inactive: create(:comment, account: account, request: req, user: user, body: 'Inativo', active: false)
            },
            comment: create(:comment, account: account, request: req, user: user, body: 'Comentário teste')
          }
        end

        before { request_with_comments }

        it 'returns requests' do
          graphql_request(query: query, variables: { filter: { accountId: account.id.to_s } })

          expect(response).to have_http_status(:ok)
          json = response.parsed_body
          expect(json['data']['listRequests']).to be_an(Array)
          expect(json['data']['listRequests'].first['title']).to eq('Solicitação de teste')
          expect(json['data']['listRequests'].first['user']['name']).to eq(user.name)
          expect(json['data']['listRequests'].first['category']['name']).to eq(category.name)
        end

        context 'with filter by status' do
          it 'returns filtered requests' do
            graphql_request(query: query, variables: { filter: { accountId: account.id.to_s, status: 'draft' } })

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            expect(json['data']['listRequests'].first['status']).to eq('draft')
          end
        end

        context 'with filter by category_id' do
          it 'returns filtered requests' do
            graphql_request(query: query,
                            variables: { filter: { accountId: account.id.to_s,
                                                   categoryId: category.id.to_s } })

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            expect(json['data']['listRequests'].first['category']['id']).to eq(category.id.to_s)
          end
        end

        context 'with filter by account_id' do
          it 'returns filtered requests' do
            graphql_request(query: query, variables: { filter: { accountId: account.id.to_s } })

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            expect(json['data']['listRequests']).not_to be_empty
          end
        end

        context 'with comments filter active false' do
          it 'returns only inactive comments when filter active false' do
            query_with_filter = <<~GQL
              query ListRequests($filter: RequestFilter!) {
                listRequests(filter: $filter) { id comments(filter: { active: false }) { id body } }
              }
            GQL
            graphql_request(query: query_with_filter, variables: { filter: { accountId: account.id.to_s } })

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            response_comments = json['data']['listRequests'].first['comments']
            expect(response_comments.pluck('body')).to include(request_with_comments[:comments][:inactive].body)
            expect(response_comments.pluck('body')).not_to include(request_with_comments[:comments][:active].body)
          end
        end

        context 'with comments' do
          it 'returns comments with request' do
            graphql_request(query: query, variables: { filter: { accountId: account.id.to_s } })
            expect(response).to have_http_status(:ok)
            response_comments = response.parsed_body['data']['listRequests'].first['comments']
            expect(response_comments).not_to be_empty
            expect(response_comments.pluck('body')).to include(request_with_comments[:comment].body)
          end
        end
      end

      context 'when account has no requests' do
        it 'returns empty array' do
          graphql_request(query: query, variables: { filter: { accountId: account.id.to_s } })

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['data']['listRequests']).to eq([])
        end
      end

      context 'when account_id is not provided' do
        it 'returns validation error' do
          graphql_request(query: query, variables: { filter: { status: 'draft' } })

          json = response.parsed_body
          expect(json['errors']).to be_present
        end
      end
    end

    describe 'listComments query' do
      let(:query) do
        <<~GQL
          query ListComments($filter: CommentFilter) {
            listComments(filter: $filter) {
              id
              body
              active
              request { id title }
              user { id name }
            }
          }
        GQL
      end

      context 'when account has comments' do
        let(:comments_data) do
          req = create(:request, account: account, user: user, category: category)
          {
            request: req,
            active: create(:comment, account: account, request: req, user: user,
                                     body: 'Comentário ativo', active: true),
            inactive: create(:comment, account: account, request: req, user: user,
                                       body: 'Comentário inativo', active: false)
          }
        end

        before { comments_data }

        it 'returns all comments when active filter is not provided' do
          graphql_request(query: query, variables: {})

          expect(response).to have_http_status(:ok)
          response_comments = response.parsed_body['data']['listComments']
          expect(response_comments.pluck('id'))
            .to contain_exactly(comments_data[:active].id.to_s, comments_data[:inactive].id.to_s)
        end

        it 'returns only active comments when filter active: true' do
          graphql_request(query: query, variables: { filter: { active: true } })

          expect(response).to have_http_status(:ok)
          response_comments = response.parsed_body['data']['listComments']
          expect(response_comments).to contain_exactly(
            hash_including('id' => comments_data[:active].id.to_s,
                           'body' => comments_data[:active].body, 'active' => true)
          )
        end

        it 'returns comments with request and user when filter active: true' do
          graphql_request(query: query, variables: { filter: { active: true } })

          expect(response).to have_http_status(:ok)
          comment_data = response.parsed_body['data']['listComments'].first
          expect(comment_data['request'])
            .to include('id' => comments_data[:request].id.to_s,
                        'title' => comments_data[:request].title)
          expect(comment_data['user']).to include('id' => user.id.to_s, 'name' => user.name)
        end

        it 'returns only inactive comments when filter active: false' do
          graphql_request(query: query, variables: { filter: { active: false } })

          expect(response).to have_http_status(:ok)
          response_comments = response.parsed_body['data']['listComments']
          expect(response_comments).to contain_exactly(
            hash_including('id' => comments_data[:inactive].id.to_s,
                           'body' => comments_data[:inactive].body, 'active' => false)
          )
        end
      end

      context 'when account has no comments' do
        it 'returns empty array' do
          graphql_request(query: query, variables: {})

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['data']['listComments']).to eq([])
        end
      end
    end

    describe 'invalid query' do
      it 'returns errors' do
        graphql_request(query: 'query { invalidField }')

        json = response.parsed_body
        expect(json['errors']).to be_present
      end
    end

    describe 'variables as JSON string' do
      it 'parses variables correctly' do
        query = <<~GQL
          query ListRequests($filter: RequestFilter!) {
            listRequests(filter: $filter) { id title }
          }
        GQL
        variables = { 'filter' => { 'accountId' => account.id.to_s } }.to_json
        post '/graphql', params: { query: query, variables: variables }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'handles blank variables string' do
        query = <<~GQL
          query { __typename }
        GQL
        post '/graphql', params: { query: query, variables: '' }, as: :json

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'request with full fields' do
      let(:request) do
        create(:request, account: account, user: user, category: category,
                         title: 'Aprovada', status: :approved, submitted_at: 1.day.ago,
                         decided_at: Time.current)
      end

      let(:query) do
        <<~GQL
          query ListRequests($filter: RequestFilter!) {
            listRequests(filter: $filter) { id title status submittedAt decidedAt rejectedReason }
          }
        GQL
      end

      before { request }

      it 'returns request with datetime fields' do
        graphql_request(query: query, variables: { filter: { accountId: account.id.to_s } })
        expect(response).to have_http_status(:ok)
        data = response.parsed_body.dig('data', 'listRequests', 0)
        expect(data['id']).to eq(request.id.to_s)
        expect(data['status']).to eq('approved')
      end
    end
  end
end
