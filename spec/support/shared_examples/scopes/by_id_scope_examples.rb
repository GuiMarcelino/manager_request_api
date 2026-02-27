# frozen_string_literal: true

RSpec.shared_examples "by_id_scope_examples" do |field|
  model = described_class.model_name.singular
  scope_name = "by_#{field}"

  describe ".#{scope_name}" do
    it "returns all #{model.pluralize} when #{field} is blank" do
      result = described_class.public_send(scope_name, nil)
      expect(result).to include(*matching_records, *excluded_records)
    end

    it "returns only #{model.pluralize} matching the given #{field}" do
      result = described_class.public_send(scope_name, filter_value)
      expect(result).to include(*matching_records)
      expect(result).not_to include(*excluded_records)
    end
  end
end
