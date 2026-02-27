# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:account) { build(:account) }
  let(:category) { build(:category, account: account) }

  describe 'associations' do
    it { expect(category).to belong_to(:account) }
  end

  describe 'validations' do
    it { expect(category).to validate_presence_of(:name) }
    it { expect(category).to validate_inclusion_of(:active).in_array([true, false]) }
  end
end
