# frozen_string_literal: true

RSpec.describe Pursuit::SearchOptions do
  subject(:search_options) { described_class.new(Product) }

  let(:title_length_node_builder) do
    proc do
      Arel::Nodes::NamedFunction.new('LENGTH', [
        Product.arel_table[:title]
      ])
    end
  end

  before do
    search_options.relation :variations, :title, :stock_status

    search_options.keyed :title
    search_options.keyed :title_length, &title_length_node_builder
    search_options.keyed :description
    search_options.keyed :rating

    search_options.unkeyed :title
    search_options.unkeyed :title_length, &title_length_node_builder
    search_options.unkeyed :description
  end

  describe '#record_class' do
    subject(:record_class) { search_options.record_class }

    it 'is expected to eq the class passed during initialization' do
      expect(record_class).to eq(Product)
    end
  end

  describe '#relations' do
    subject(:relations) { search_options.relations }

    it 'is expected to contain the correct relations' do
      expect(relations).to eq(variations: %i[title stock_status])
    end
  end

  describe '#keyed_attributes' do
    subject(:keyed_attributes) { search_options.keyed_attributes }

    it 'is expected to contain the correct keyed attributes' do
      expect(keyed_attributes.keys).to contain_exactly(:title, :title_length, :description, :rating)
    end

    it 'is expected to set a default node builder for attributes declared without a block' do
      expect(keyed_attributes[:title].call).to eq(Product.arel_table[:title])
    end

    it 'is expected to set a custom node builder for attributes declared with a block' do
      expect(keyed_attributes[:title_length]).to eq(title_length_node_builder)
    end
  end

  describe '#unkeyed_attributes' do
    subject(:unkeyed_attributes) { search_options.unkeyed_attributes }

    it 'is expected to contain the correct unkeyed attributes' do
      expect(unkeyed_attributes.keys).to contain_exactly(:title, :title_length, :description)
    end

    it 'is expected to set a default node builder for attributes declared without a block' do
      expect(unkeyed_attributes[:title].call).to eq(Product.arel_table[:title])
    end

    it 'is expected to set a custom node builder for attributes declared with a block' do
      expect(unkeyed_attributes[:title_length]).to eq(title_length_node_builder)
    end
  end
end
