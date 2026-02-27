# frozen_string_literal: true

RSpec.shared_examples 'by_value_scope_examples' do |field|
  model = described_class.model_name.singular

  describe ".#{"by_#{field}"}" do
    it "returns all #{model.pluralize} when #{field} is blank" do
      result = described_class.public_send("by_#{field}", nil)
      expect(result).to include(*matching_records, *excluded_records)
    end

    it "returns only #{model.pluralize} matching the given #{field}" do
      result = described_class.public_send("by_#{field}", filter_value)
      expect(result).to include(*matching_records)
      expect(result).not_to include(*excluded_records)
    end
  end
end
