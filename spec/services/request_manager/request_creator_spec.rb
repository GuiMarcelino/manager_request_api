# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestManager::RequestCreator, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:category) { create(:category, account: account) }
  let(:title) { "Solicitação de teste" }
  let(:description) { "Descrição opcional" }

  describe "#call" do
    subject do
      described_class.new(
        account: account,
        user: user,
        title: title,
        category: category,
        description: description
      ).call
    end

    context "when params are valid" do
      it { is_expected.to be_success }

      it "returns the created request as payload" do
        expect(subject.payload).to be_a(Request)
      end

      it "returns a persisted request" do
        expect(subject.payload).to be_persisted
      end

      it "creates request in draft status" do
        expect(subject.payload.status).to eq "draft"
      end

      it "associates request to account" do
        expect(subject.payload.account_id).to eq account.id
      end

      it "associates request to user" do
        expect(subject.payload.user_id).to eq user.id
      end

      it "associates request to category" do
        expect(subject.payload.category_id).to eq category.id
      end

      it "sets title" do
        expect(subject.payload.title).to eq title
      end

      it "sets description" do
        expect(subject.payload.description).to eq description
      end
    end

    context "when user does not belong to account" do
      let(:other_account) { create(:account) }
      let(:user_from_other_account) { create(:user, account: other_account) }

      subject do
        described_class.new(
          account: account,
          user: user_from_other_account,
          title: title,
          category: category,
          description: description
        ).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns error message" do
        expect(subject.errors[:message]).to eq "User does not belong to account"
      end
    end

    context "when category does not belong to account" do
      let(:other_account) { create(:account) }
      let(:category_from_other_account) { create(:category, account: other_account) }

      subject do
        described_class.new(
          account: account,
          user: user,
          title: title,
          category: category_from_other_account,
          description: description
        ).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns error message" do
        expect(subject.errors[:message]).to eq "Category does not belong to account"
      end
    end

    context "when title is blank" do
      let(:title) { "" }

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end
    end

    context "when account is missing" do
      subject do
        described_class.new(
          account: nil,
          user: user,
          title: title,
          category: category,
          description: description
        ).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns missing param message" do
        expect(subject.errors[:message]).to eq "Missing required param: account"
      end
    end

    context "when user is missing" do
      subject do
        described_class.new(
          account: account,
          user: nil,
          title: title,
          category: category,
          description: description
        ).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns missing param message" do
        expect(subject.errors[:message]).to eq "Missing required param: user"
      end
    end

    context "when title is missing" do
      subject do
        described_class.new(
          account: account,
          user: user,
          title: nil,
          category: category,
          description: description
        ).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns missing param message" do
        expect(subject.errors[:message]).to eq "Missing required param: title"
      end
    end

    context "when category is missing" do
      subject do
        described_class.new(
          account: account,
          user: user,
          title: title,
          category: nil,
          description: description
        ).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns missing param message" do
        expect(subject.errors[:message]).to eq "Missing required param: category"
      end
    end
  end
end
