# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestManager::RequestLister, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:ability) { Ability.new(user) }
  let(:category) { create(:category, account: account) }

  describe '#call' do
    context 'when filtering by account_id only' do
      subject(:result) do
        described_class.new(ability: ability, account_id: account.id).call
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
        described_class.new(ability: ability, account_id: account.id, status: 'draft').call
      end

      let(:requests) do
        {
          draft: create(:request, account: account, user: user, category: category, status: :draft),
          approved: create(:request, account: account, user: user, category: category, status: :approved)
        }
      end

      before { requests }

      it { is_expected.to be_success }

      it 'returns only requests with the given status' do
        expect(result.payload).to include(requests[:draft])
        expect(result.payload).not_to include(requests[:approved])
      end
    end

    context 'when filtering by account_id and category_id' do
      subject(:result) do
        described_class.new(ability: ability, account_id: account.id, category_id: category.id).call
      end

      let(:requests) do
        {
          in_category: create(:request, account: account, user: user, category: category, status: :draft),
          other: create(:request, account: account, user: user,
                                  category: create(:category, account: account), status: :draft)
        }
      end

      before { requests }

      it { is_expected.to be_success }

      it 'returns only requests in the given category' do
        expect(result.payload).to include(requests[:in_category])
        expect(result.payload).not_to include(requests[:other])
      end
    end

    context 'when filtering by account_id, status and category_id' do
      subject(:result) do
        described_class.new(
          ability: ability,
          account_id: account.id,
          status: 'approved',
          category_id: category.id
        ).call
      end

      let(:requests) do
        {
          matching: create(:request, account: account, user: user, category: category, status: :approved),
          excluded1: create(:request, account: account, user: user, category: category, status: :draft),
          excluded2: create(:request, account: account, user: user,
                                      category: create(:category, account: account), status: :approved)
        }
      end

      before { requests }

      it { is_expected.to be_success }

      it 'returns only requests matching all filters' do
        expect(result.payload).to include(requests[:matching])
        expect(result.payload).not_to include(requests[:excluded1])
        expect(result.payload).not_to include(requests[:excluded2])
      end
    end

    context 'when account_id is missing' do
      subject(:result) do
        described_class.new(ability: ability, status: 'draft').call
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
        described_class.new(ability: ability, account_id: nil).call
      end

      it { is_expected.not_to be_success }
    end

    context 'when ability is missing' do
      subject(:result) do
        described_class.new(account_id: account.id).call
      end

      it { is_expected.not_to be_success }

      it 'returns missing param message' do
        expect(result.errors[:message]).to eq 'Missing required param: ability'
      end
    end

    context 'when passing account object' do
      subject(:result) do
        described_class.new(ability: ability, account: account).call
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
