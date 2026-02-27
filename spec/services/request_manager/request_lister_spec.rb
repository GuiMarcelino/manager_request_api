# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestManager::RequestLister, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:category) { create(:category, account: account) }

  describe "#call" do
    context "when filtering by account_id only" do
      let!(:request) do
        create(:request, account: account, user: user, category: category, status: :draft)
      end

      subject do
        described_class.new(account_id: account.id).call
      end

      it { is_expected.to be_success }

      it "returns requests for the account" do
        expect(subject.payload).to include(request)
      end

      it "excludes requests from other accounts" do
        other_account = create(:account)
        other_request = create(:request, account: other_account,
          user: create(:user, account: other_account),
          category: create(:category, account: other_account))

        expect(subject.payload).not_to include(other_request)
      end
    end

    context "when filtering by account_id and status" do
      let!(:draft_request) do
        create(:request, account: account, user: user, category: category, status: :draft)
      end
      let!(:approved_request) do
        create(:request, account: account, user: user, category: category, status: :approved)
      end

      subject do
        described_class.new(account_id: account.id, status: "draft").call
      end

      it { is_expected.to be_success }

      it "returns only requests with the given status" do
        expect(subject.payload).to include(draft_request)
        expect(subject.payload).not_to include(approved_request)
      end
    end

    context "when filtering by account_id and category_id" do
      let(:other_category) { create(:category, account: account) }
      let!(:request_in_category) do
        create(:request, account: account, user: user, category: category, status: :draft)
      end
      let!(:request_in_other_category) do
        create(:request, account: account, user: user, category: other_category, status: :draft)
      end

      subject do
        described_class.new(account_id: account.id, category_id: category.id).call
      end

      it { is_expected.to be_success }

      it "returns only requests in the given category" do
        expect(subject.payload).to include(request_in_category)
        expect(subject.payload).not_to include(request_in_other_category)
      end
    end

    context "when filtering by account_id, status and category_id" do
      let!(:matching_request) do
        create(:request, account: account, user: user, category: category, status: :approved)
      end
      let!(:wrong_status) do
        create(:request, account: account, user: user, category: category, status: :draft)
      end
      let(:other_category) { create(:category, account: account) }
      let!(:wrong_category) do
        create(:request, account: account, user: user, category: other_category, status: :approved)
      end

      subject do
        described_class.new(
          account_id: account.id,
          status: "approved",
          category_id: category.id
        ).call
      end

      it { is_expected.to be_success }

      it "returns only requests matching all filters" do
        expect(subject.payload).to include(matching_request)
        expect(subject.payload).not_to include(wrong_status)
        expect(subject.payload).not_to include(wrong_category)
      end
    end

    context "when account_id is missing" do
      subject do
        described_class.new(status: "draft").call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end

      it "returns missing param message" do
        expect(subject.errors[:message]).to eq "Missing required param: account_id"
      end
    end

    context "when account_id is nil" do
      subject do
        described_class.new(account_id: nil).call
      end

      it { is_expected.not_to be_success }
    end

    context "when passing account object" do
      let!(:request) do
        create(:request, account: account, user: user, category: category)
      end

      subject do
        described_class.new(account: account).call
      end

      it { is_expected.to be_success }

      it "uses account id for filtering" do
        expect(subject.payload).to include(request)
      end
    end
  end
end
