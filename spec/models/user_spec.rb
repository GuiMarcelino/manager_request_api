# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:account) { build(:account) }
  let(:user) { build(:user, account: account) }

  describe "associations" do
    it { expect(user).to belong_to(:account) }
  end

  describe "validations" do
    it { expect(user).to validate_presence_of(:name) }
    it { expect(user).to validate_presence_of(:email) }
    it { expect(user).to validate_uniqueness_of(:email).scoped_to(:account_id) }
  end

  describe "enumerize" do
    context "with role" do

      let(:roles) do
        %i[viewer editor admin].freeze
      end

      it { is_expected.to enumerize(:role).in(roles) }
    end
  end
end
