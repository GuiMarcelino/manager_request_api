# frozen_string_literal: true

require "rails_helper"

RSpec.describe Request, type: :model do
  subject(:request) { build(:request, account: account, user: user, category: category) }

  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:category) { create(:category, account: account) }

  describe "associations" do
    it { expect(request).to belong_to(:account) }
    it { expect(request).to belong_to(:user) }
    it { expect(request).to belong_to(:category) }
    it { expect(request).to have_many(:comments) }
  end

  describe "validations" do
    it { expect(request).to validate_presence_of(:title) }
  end

  describe "enumerize" do
    context "with status" do
      let(:statuses) { %i[draft pending_approval approved rejected].freeze }

      it { is_expected.to enumerize(:status).in(statuses) }
    end
  end

  describe "scopes" do
    let!(:first_object) do
      create(:request, account: account, user: user, category: category, status: :draft)
    end

    let!(:second_object) do
      create(:request, account: account, user: user, category: category, status: :approved)
    end

    let(:other_account) { create(:account) }
    let(:other_category) { create(:category, account: account) }

    let!(:request_other_account) do
      create(:request, account: other_account, user: create(:user, account: other_account),
        category: create(:category, account: other_account), status: :draft)
    end

    let!(:request_other_category) do
      create(:request, account: account, user: user, category: other_category, status: :draft)
    end

    describe ".by_account_id" do
      it_behaves_like "by_id_scope_examples", "account_id" do
        let(:matching_records) { [first_object, second_object, request_other_category] }
        let(:excluded_records) { [request_other_account] }
        let(:filter_value) { account.id }
      end
    end

    describe ".by_status" do
      it_behaves_like "by_value_scope_examples", "status" do
        let(:matching_records) { [first_object, request_other_account, request_other_category] }
        let(:excluded_records) { [second_object] }
        let(:filter_value) { "draft" }
      end

      context "when filtering by approved" do
        it "returns only approved requests" do
          result = described_class.by_status("approved")
          expect(result).to include(second_object)
          expect(result).not_to include(first_object)
        end
      end
    end

    describe ".by_category_id" do
      it_behaves_like "by_id_scope_examples", "category_id" do
        let(:matching_records) { [first_object, second_object] }
        let(:excluded_records) { [request_other_category] }
        let(:filter_value) { category.id }
      end
    end
  end
end
