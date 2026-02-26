# frozen_string_literal: true

require "rails_helper"

RSpec.describe Request, type: :model do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:category) { create(:category, account: account) }
  let(:request) { build(:request, account: account, user: user, category: category) }

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
      subject { request }

      let(:statuses) do
        %i[draft pending_approval approved rejected].freeze
      end

      it { is_expected.to enumerize(:status).in(statuses) }
    end
  end
end
