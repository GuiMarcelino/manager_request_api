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
    # rubocop:disable RSpec/LetSetup -- active_record and inactive_record are used by shared example
    let!(:active_record) do
      create(:comment, account: account, request: request, user: user, active: true)
    end

    let!(:inactive_record) do
      create(:comment, account: account, request: request, user: user, active: false)
    end
    # rubocop:enable RSpec/LetSetup

    it_behaves_like 'by_active_scope_examples'
  end
end
