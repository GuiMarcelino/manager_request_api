# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account, type: :model do
  let(:account) { build(:account) }

  describe "associations" do
    it { expect(account).to have_many(:users) }
    it { expect(account).to have_many(:categories) }
    it { expect(account).to have_many(:requests) }
    it { expect(account).to have_many(:comments) }
  end

  describe "validations" do
    it { expect(account).to validate_presence_of(:name) }
    it { expect(account).to validate_presence_of(:cnpj) }
  end

  describe "cnpj validation" do
    context "when cnpj is invalid" do
      before do
        account.cnpj = "00000000000000"
      end

      it "is invalid" do
        account.valid?

        expect(account.errors[:cnpj]).to include(I18n.t("errors.messages.invalid"))
      end
    end

    context "when cnpj is valid" do
      it "is valid" do
        expect(account).to be_valid
      end
    end
  end
end
