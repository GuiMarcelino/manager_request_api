# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestManager::RequestLister, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:category) { create(:category, account: account) }

  describe '#call' do
    context 'when filtering by account_id only' do
      subject(:result) do
        described_class.new(account_id: account.id).call
      end

      let!(:request) do
        create(:request, account: account, user: user, category: category, status: :draft)
      end

      it { is_expected.to be_success }

      it 'returns requests for the account' do
        expect(result.payload).to include(request)
      end

      it 'excludes requests from other accounts' do
        other_account = create(:account)
        other_request = create(:request, account: other_account,
                                         user: create(:user, account: other_account),
                                         category: create(:category, account: other_account))

        expect(result.payload).not_to include(other_request)
      end
    end

    context 'when filtering by account_id and status' do
      subject(:result) do
        described_class.new(account_id: account.id, status: 'draft').call
      end

      let!(:draft_request) do
        create(:request, account: account, user: user, category: category, status: :draft)
      end
      let!(:approved_request) do
        create(:request, account: account, user: user, category: category, status: :approved)
      end

      it { is_expected.to be_success }

      it 'returns only requests with the given status' do
        expect(result.payload).to include(draft_request)
        expect(result.payload).not_to include(approved_request)
      end
    end

    context 'when filtering by account_id and category_id' do
      subject(:result) do
        described_class.new(account_id: account.id, category_id: category.id).call
      end

      let!(:request_in_category) do
        create(:request, account: account, user: user, category: category, status: :draft)
      end
      let!(:request_in_other_category) do
        create(:request, account: account, user: user,
                         category: create(:category, account: account), status: :draft)
      end

      it { is_expected.to be_success }

      it 'returns only requests in the given category' do
        expect(result.payload).to include(request_in_category)
        expect(result.payload).not_to include(request_in_other_category)
      end
    end

    context 'when filtering by account_id, status and category_id' do
      subject(:result) do
        described_class.new(
          account_id: account.id,
          status: 'approved',
          category_id: category.id
        ).call
      end

      let!(:matching_request) do
        create(:request, account: account, user: user, category: category, status: :approved)
      end
      let!(:excluded_requests) do
        [
          create(:request, account: account, user: user, category: category, status: :draft),
          create(:request, account: account, user: user,
                           category: create(:category, account: account), status: :approved)
        ]
      end

      it { is_expected.to be_success }

      it 'returns only requests matching all filters' do
        expect(result.payload).to include(matching_request)
        expect(result.payload).not_to include(excluded_requests[0])
        expect(result.payload).not_to include(excluded_requests[1])
      end
    end

    context 'when account_id is missing' do
      subject(:result) do
        described_class.new(status: 'draft').call
      end

      it { is_expected.not_to be_success }

      it 'returns a 422 error code' do
        expect(result.errors[:code]).to eq 422
      end

      it 'returns missing param message' do
        expect(result.errors[:message]).to eq 'Missing required param: account_id'
      end
    end

    context 'when account_id is nil' do
      subject(:result) do
        described_class.new(account_id: nil).call
      end

      it { is_expected.not_to be_success }
    end

    context 'when passing account object' do
      subject(:result) do
        described_class.new(account: account).call
      end

      let!(:request) do
        create(:request, account: account, user: user, category: category)
      end

      it { is_expected.to be_success }

      it 'uses account id for filtering' do
        expect(result.payload).to include(request)
      end
    end
  end
end
