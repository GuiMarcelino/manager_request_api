# frozen_string_literal: true

RSpec.shared_examples 'by_active_scope_examples' do
  model = described_class.model_name.singular

  describe '.by_active' do
    it "returns all #{model.pluralize} when active is nil" do
      result = described_class.by_active(nil)
      expect(result).to contain_exactly(active_record, inactive_record)
    end

    it "returns only active #{model.pluralize} when active is true" do
      result = described_class.by_active(true)
      expect(result).to contain_exactly(active_record)
    end

    it "returns only inactive #{model.pluralize} when active is false" do
      result = described_class.by_active(false)
      expect(result).to contain_exactly(inactive_record)
    end
  end
end
