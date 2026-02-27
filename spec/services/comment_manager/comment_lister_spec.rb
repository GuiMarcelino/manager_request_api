# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentManager::CommentLister, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:ability) { Ability.new(user) }
  let(:request) { create(:request, account: account, user: user, category: create(:category, account: account)) }

  describe '#call' do
    before { Comment.delete_all }

    context 'when active filter is not provided' do
      subject(:result) { described_class.new(ability: ability).call }

      let(:comments) do
        {
          active: create(:comment, account: account, request: request, user: user, body: 'Ativo', active: true),
          inactive: create(:comment, account: account, request: request, user: user, body: 'Inativo', active: false)
        }
      end

      before { comments }

      it { is_expected.to be_success }

      it 'returns all comments' do
        expect(result.payload).to contain_exactly(comments[:active], comments[:inactive])
      end
    end

    context 'when filtering by active: true' do
      subject(:result) { described_class.new(ability: ability, active: true).call }

      let(:comments) do
        {
          active: create(:comment, account: account, request: request, user: user, body: 'Ativo', active: true),
          inactive: create(:comment, account: account, request: request, user: user, body: 'Inativo', active: false)
        }
      end

      before { comments }

      it { is_expected.to be_success }

      it 'returns only active comments' do
        expect(result.payload).to contain_exactly(comments[:active])
        expect(result.payload).not_to include(comments[:inactive])
      end
    end

    context 'when filtering by active: false' do
      subject(:result) { described_class.new(ability: ability, active: false).call }

      let(:comments) do
        {
          active: create(:comment, account: account, request: request, user: user, body: 'Ativo', active: true),
          inactive: create(:comment, account: account, request: request, user: user, body: 'Inativo', active: false)
        }
      end

      before { comments }

      it { is_expected.to be_success }

      it 'returns only inactive comments' do
        expect(result.payload).to contain_exactly(comments[:inactive])
        expect(result.payload).not_to include(comments[:active])
      end
    end
  end
end
