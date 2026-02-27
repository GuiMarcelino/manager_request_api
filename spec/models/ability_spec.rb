# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:account) { create(:account) }

  describe 'admin' do
    let(:admin) { create(:user, account: account, role: :admin) }
    let(:ability) { described_class.new(admin) }

    it 'can manage requests and comments in their account' do
      expect(ability.can?(:manage, Request.new(account_id: account.id))).to be true
      expect(ability.can?(:manage, Comment.new(account_id: account.id))).to be true
    end

    it 'cannot access resources from other accounts' do
      other_account = create(:account)
      expect(ability.can?(:manage, Request.new(account_id: other_account.id))).to be false
      expect(ability.can?(:manage, Comment.new(account_id: other_account.id))).to be false
    end
  end

  describe 'editor' do
    let(:editor) { create(:user, account: account, role: :editor) }
    let(:ability) { described_class.new(editor) }

    it 'can create and read requests' do
      expect(ability.can?(:create, Request.new(account_id: account.id))).to be true
      expect(ability.can?(:read, Request.new(account_id: account.id))).to be true
    end

    it 'can submit draft requests' do
      draft = Request.new(account_id: account.id, status: 'draft')
      expect(ability.can?(:submit, draft)).to be true
    end

    it 'cannot submit non-draft requests' do
      pending_req = Request.new(account_id: account.id, status: 'pending_approval')
      expect(ability.can?(:submit, pending_req)).to be false
    end

    it 'cannot approve or reject requests' do
      req = Request.new(account_id: account.id)
      expect(ability.can?(:approve, req)).to be false
      expect(ability.can?(:reject, req)).to be false
    end

    it 'can create and read comments' do
      expect(ability.can?(:create, Comment.new(account_id: account.id))).to be true
      expect(ability.can?(:read, Comment.new(account_id: account.id))).to be true
    end

    it 'cannot destroy comments' do
      expect(ability.can?(:destroy, Comment.new(account_id: account.id))).to be false
    end
  end

  describe 'viewer' do
    let(:viewer) { create(:user, account: account, role: :viewer) }
    let(:ability) { described_class.new(viewer) }

    it 'can only read requests and comments' do
      expect(ability.can?(:read, Request.new(account_id: account.id))).to be true
      expect(ability.can?(:read, Comment.new(account_id: account.id))).to be true
    end

    it 'cannot create, submit, approve, or reject requests' do
      req = Request.new(account_id: account.id)
      expect(ability.can?(:create, Request)).to be false
      expect(ability.can?(:submit, req)).to be false
      expect(ability.can?(:approve, req)).to be false
      expect(ability.can?(:reject, req)).to be false
    end

    it 'cannot create or destroy comments' do
      expect(ability.can?(:create, Comment)).to be false
      expect(ability.can?(:destroy, Comment.new(account_id: account.id))).to be false
    end
  end

  describe 'nil user' do
    let(:ability) { described_class.new(nil) }

    it 'has no permissions' do
      expect(ability.can?(:read, Request.new(account_id: account.id))).to be false
      expect(ability.can?(:create, Request)).to be false
    end
  end
end
