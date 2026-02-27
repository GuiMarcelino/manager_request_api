# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentManager::CommentCreator, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:request) { create(:request, account: account, user: user, category: create(:category, account: account)) }
  let(:body) { 'Comentário de teste' }

  describe '#call' do
    subject(:result) do
      described_class.new(
        account: account,
        request: request,
        user: user,
        body: body
      ).call
    end

    context 'when params are valid' do
      it { is_expected.to be_success }

      it 'returns the created comment as payload' do
        expect(result.payload).to be_a(Comment)
      end

      it 'returns a persisted comment' do
        expect(result.payload).to be_persisted
      end

      it 'associates comment to account' do
        expect(result.payload.account_id).to eq account.id
      end

      it 'associates comment to request' do
        expect(result.payload.request_id).to eq request.id
      end

      it 'associates comment to user' do
        expect(result.payload.user_id).to eq user.id
      end

      it 'sets body' do
        expect(result.payload.body).to eq body
      end
    end

    context 'when request does not belong to account' do
      subject(:result) do
        other_acct = create(:account)
        other_req = create(:request, account: other_acct,
                                     user: create(:user, account: other_acct),
                                     category: create(:category, account: other_acct))
        described_class.new(account: account, request: other_req, user: user, body: body).call
      end

      it { is_expected.not_to be_success }

      it 'returns a 422 error code' do
        expect(result.errors[:code]).to eq 422
      end

      it 'returns error message' do
        expect(result.errors[:message]).to eq 'Request does not belong to account'
      end
    end
  end
end
