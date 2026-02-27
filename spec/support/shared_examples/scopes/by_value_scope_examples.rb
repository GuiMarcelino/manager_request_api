# frozen_string_literal: true

RSpec.shared_examples 'by_value_scope_examples' do |field|
  model = described_class.model_name.singular

  describe ".#{"by_#{field}"}" do
    it "returns all #{model.pluralize} when #{field} is blank" do
      data = scope_test_data
      result = described_class.public_send("by_#{field}", nil)
      expect(result).to include(*data[:matching_records], *data[:excluded_records])
    end

    it "returns only #{model.pluralize} matching the given #{field}" do
      data = scope_test_data
      result = described_class.public_send("by_#{field}", data[:filter_value])
      expect(result).to include(*data[:matching_records])
      expect(result).not_to include(*data[:excluded_records])
    end
  end
end
