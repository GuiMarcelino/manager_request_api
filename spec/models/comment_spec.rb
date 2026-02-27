# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) { build(:comment, account: account, request: request, user: user) }

  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:request) { create(:request, account: account, user: user, category: create(:category, account: account)) }

  describe 'associations' do
    it { expect(comment).to belong_to(:account) }
    it { expect(comment).to belong_to(:request) }
    it { expect(comment).to belong_to(:user) }
  end

  describe 'validations' do
    it { expect(comment).to validate_presence_of(:body) }
  end

  describe 'scopes' do
    describe '.by_active' do
      before { described_class.delete_all }

      let(:active_comment) do
        create(:comment, account: account, request: request, user: user, body: 'Ativo', active: true)
      end

      let(:inactive_comment) do
        create(:comment, account: account, request: request, user: user, body: 'Inativo', active: false)
      end

      it 'returns only active comments when active is true' do
        result = described_class.by_active(true)

        expect(result).to contain_exactly(active_comment)
        expect(result).not_to include(inactive_comment)
      end

      it 'returns only inactive comments when active is false' do
        result = described_class.by_active(false)

        expect(result).to contain_exactly(inactive_comment)
        expect(result).not_to include(active_comment)
      end
    end
  end
end
