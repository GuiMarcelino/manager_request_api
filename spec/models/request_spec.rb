# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request, type: :model do
  subject(:request) { build(:request, account: account, user: user, category: category) }

  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:category) { create(:category, account: account) }

  describe 'associations' do
    it { expect(request).to belong_to(:account) }
    it { expect(request).to belong_to(:user) }
    it { expect(request).to belong_to(:category) }
    it { expect(request).to have_many(:comments) }
  end

  describe 'validations' do
    it { expect(request).to validate_presence_of(:title) }
  end

  describe 'enumerize' do
    context 'with status' do
      let(:statuses) { %i[draft pending_approval approved rejected].freeze }

      it { is_expected.to enumerize(:status).in(statuses) }
    end
  end

  describe 'scopes' do
    describe '.by_account_id' do
      it_behaves_like 'by_id_scope_examples', 'account_id' do
        let(:scope_test_data) do
          other_acc = create(:account)
          other_cat = create(:category, account: account)
          first = create(:request, account: account, user: user, category: category, status: :draft)
          second = create(:request, account: account, user: user, category: category, status: :approved)
          req_other_acc = create(:request, account: other_acc,
                                           user: create(:user, account: other_acc),
                                           category: create(:category, account: other_acc),
                                           status: :draft)
          req_other_cat = create(:request, account: account, user: user, category: other_cat, status: :draft)
          {
            matching_records: [first, second, req_other_cat],
            excluded_records: [req_other_acc],
            filter_value: account.id
          }
        end
      end
    end

    describe '.by_status' do
      let(:scope_test_data) do
        other_acc = create(:account)
        other_cat = create(:category, account: account)
        first = create(:request, account: account, user: user, category: category, status: :draft)
        second = create(:request, account: account, user: user, category: category, status: :approved)
        req_other_acc = create(:request, account: other_acc,
                                         user: create(:user, account: other_acc),
                                         category: create(:category, account: other_acc),
                                         status: :draft)
        req_other_cat = create(:request, account: account, user: user, category: other_cat, status: :draft)
        {
          matching_records: [first, req_other_acc, req_other_cat],
          excluded_records: [second],
          filter_value: 'draft',
          first: first,
          second: second
        }
      end

      it_behaves_like 'by_value_scope_examples', 'status'

      context 'when filtering by approved' do
        it 'returns only approved requests' do
          result = described_class.by_status('approved')
          expect(result).to include(scope_test_data[:second])
          expect(result).not_to include(scope_test_data[:first])
        end
      end
    end

    describe '.by_category_id' do
      it_behaves_like 'by_id_scope_examples', 'category_id' do
        let(:scope_test_data) do
          other_cat = create(:category, account: account)
          first = create(:request, account: account, user: user, category: category, status: :draft)
          second = create(:request, account: account, user: user, category: category, status: :approved)
          req_other_cat = create(:request, account: account, user: user, category: other_cat, status: :draft)
          {
            matching_records: [first, second],
            excluded_records: [req_other_cat],
            filter_value: category.id
          }
        end
      end
    end
  end
end
