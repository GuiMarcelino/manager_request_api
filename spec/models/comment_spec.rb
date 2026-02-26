# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:request) { create(:request, account: account, user: user, category: create(:category, account: account)) }
  let(:comment) { build(:comment, account: account, request: request, user: user) }

  describe "associations" do
    it { expect(comment).to belong_to(:account) }
    it { expect(comment).to belong_to(:request) }
    it { expect(comment).to belong_to(:user) }
  end

  describe "validations" do
    it { expect(comment).to validate_presence_of(:body) }
  end
end
