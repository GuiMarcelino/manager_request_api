# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL API", type: :request do
  let(:account) { create(:account, name: "Conta Teste", cnpj: CNPJ.generate) }
  let(:user) { create(:user, account: account, name: "Usuário Teste", email: "teste@example.com", role: :admin) }
  let(:category) { create(:category, account: account, name: "Categoria Teste") }

  before do
    Comment.delete_all
    Request.delete_all
    Category.delete_all
    User.delete_all
    Account.delete_all

    account
    user
    category

    allow_any_instance_of(GraphqlController).to receive(:default_user).and_return(user)
    allow_any_instance_of(GraphqlController).to receive(:default_account).and_return(account)
  end

  def graphql_request(query:, variables: {})
    post "/graphql", params: { query: query, variables: variables }, as: :json
  end

  describe "POST /graphql" do
    describe "listRequests query" do
      let(:query) do
        <<~GQL
          query ListRequests($filter: RequestFilter) {
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

      context "when account has requests" do
        let!(:request) do
          create(:request, account: account, user: user, category: category, title: "Solicitação de teste")
        end

        it "returns requests" do
          graphql_request(query: query)

          expect(response).to have_http_status(:ok)
          json = response.parsed_body
          expect(json["data"]["listRequests"]).to be_an(Array)
          expect(json["data"]["listRequests"].first["title"]).to eq("Solicitação de teste")
          expect(json["data"]["listRequests"].first["user"]["name"]).to eq(user.name)
          expect(json["data"]["listRequests"].first["category"]["name"]).to eq(category.name)
        end

        context "with filter by status" do
          it "returns filtered requests" do
            graphql_request(query: query, variables: { filter: { status: "draft" } })

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            expect(json["data"]["listRequests"].first["status"]).to eq("draft")
          end
        end

        context "with filter by category_id" do
          it "returns filtered requests" do
            graphql_request(query: query, variables: { filter: { categoryId: category.id.to_s } })

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            expect(json["data"]["listRequests"].first["category"]["id"]).to eq(category.id.to_s)
          end
        end

        context "with filter by account_id" do
          it "returns filtered requests" do
            graphql_request(query: query, variables: { filter: { accountId: account.id.to_s } })

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            expect(json["data"]["listRequests"]).not_to be_empty
          end
        end

        context "with comments filter active false" do
          let!(:active_comment) do
            create(:comment, account: account, request: request, user: user, body: "Ativo", active: true)
          end
          let!(:inactive_comment) do
            create(:comment, account: account, request: request, user: user, body: "Inativo", active: false)
          end

          it "returns only inactive comments when filter active false" do
            query_with_filter = <<~GQL
              query ListRequests { listRequests { id comments(filter: { active: false }) { id body } } }
            GQL
            graphql_request(query: query_with_filter)

            expect(response).to have_http_status(:ok)
            json = response.parsed_body
            comments = json["data"]["listRequests"].first["comments"]
            expect(comments.map { |c| c["body"] }).to include("Inativo")
            expect(comments.map { |c| c["body"] }).not_to include("Ativo")
          end
        end

        context "with comments" do
          let!(:comment) do
            create(:comment, account: account, request: request, user: user, body: "Comentário teste")
          end

          it "returns comments with request" do
            graphql_request(query: query)
            expect(response).to have_http_status(:ok)
            expect(response.parsed_body["data"]["listRequests"].first["comments"]).not_to be_empty
          end
        end
      end

      context "when account has no requests" do
        it "returns empty array" do
          graphql_request(query: query)

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"]["listRequests"]).to eq([])
        end
      end
    end

    describe "invalid query" do
      it "returns errors" do
        graphql_request(query: "query { invalidField }")

        json = response.parsed_body
        expect(json["errors"]).to be_present
      end
    end

    describe "variables as JSON string" do
      it "parses variables correctly" do
        query = <<~GQL
          query ListRequests { listRequests { id title } }
        GQL
        post "/graphql", params: { query: query, variables: '{"foo": "bar"}' }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it "handles blank variables string" do
        query = <<~GQL
          query ListRequests { listRequests { id title } }
        GQL
        post "/graphql", params: { query: query, variables: "" }, as: :json

        expect(response).to have_http_status(:ok)
      end
    end

    describe "request with full fields" do
      let!(:request) do
        create(:request, account: account, user: user, category: category,
          title: "Aprovada", status: :approved, submitted_at: 1.day.ago, decided_at: Time.current)
      end

      let(:query) do
        <<~GQL
          query { listRequests { id title status submittedAt decidedAt rejectedReason } }
        GQL
      end

      it "returns request with datetime fields" do
        graphql_request(query: query)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig("data", "listRequests", 0, "status")).to eq("approved")
      end
    end
  end
end
