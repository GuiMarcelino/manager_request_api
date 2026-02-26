# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentManager::CommentCreator, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:request) { create(:request, account: account, user: user, category: create(:category, account: account)) }
  let(:body) { "Comentário de teste" }

  describe "#call" do
    subject do
      described_class.new(
        account: account,
        request: request,
        user: user,
        body: body
      ).call
    end

    context "when params are valid" do
      it { is_expected.to be_success }

      it "returns the created comment as payload" do
        expect(subject.payload).to be_a(Comment)
      end

      it "returns a persisted comment" do
        expect(subject.payload).to be_persisted
      end

      it "associates comment to account" do
        expect(subject.payload.account_id).to eq account.id
      end

      it "associates comment to request" do
        expect(subject.payload.request_id).to eq request.id
      end

      it "associates comment to user" do
        expect(subject.payload.user_id).to eq user.id
      end

      it "sets body" do
        expect(subject.payload.body).to eq body
      end
    end

    context "when request does not belong to account" do
      let(:other_account) { create(:account) }
      let(:other_user)    { create(:user, account: other_account) }
      let(:other_category){ create(:category, account: other_account) }

      let(:request_from_other_account) do
        create(
          :request,
          account: other_account,
          user: other_user,
          category: other_category
        )
      end

      subject do
        described_class.new(
          account: account,
          request: request_from_other_account,
          user: user,
          body: body
        ).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns error message" do
        expect(subject.errors[:message]).to eq "Request does not belong to account"
      end
    end
  end
end
