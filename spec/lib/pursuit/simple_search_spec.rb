# frozen_string_literal: true

RSpec.describe Pursuit::SimpleSearch do
  subject(:simple_search) do
    described_class.new(
      Product.left_outer_joins(:variations).group(:id)
    ) do
      search_attribute :title
      search_attribute ProductVariation.arel_table[:title]
    end
  end

  describe '#initialize' do
    it 'is expected to set #relation eq `relation`' do
      expect(simple_search).to have_attributes(relation: Product.left_outer_joins(:variations).group(:id))
    end

    it 'is expected to evaluate the passed block' do
      expect(simple_search.attributes).to be_present
    end
  end

  describe '#search_attribute' do
    subject(:search_attribute) do
      simple_search.search_attribute(ProductVariation.arel_table[:currency])
    end

    it 'is expected to add the attribute to #attributes' do
      search_attribute
      expect(simple_search.attributes).to include(ProductVariation.arel_table[:currency])
    end
  end

  describe '#parse' do
    subject(:parse) { simple_search.parse('Shirt') }

    it 'is expected to equal the ARel node' do
      expect(parse).to eq(
        Product.arel_table[:title].matches('%Shirt%').or(
          ProductVariation.arel_table[:title].matches('%Shirt%')
        )
      )
    end
  end

  describe '#apply' do
    subject(:apply) { simple_search.apply('Shirt') }

    it 'is expected to equal #relation with clauses applied' do
      expect(apply).to eq(
        Product.left_outer_joins(:variations).group(:id).where(
          Product.arel_table[:title].matches('%Shirt%').or(
            ProductVariation.arel_table[:title].matches('%Shirt%')
          )
        )
      )
    end
  end
end
