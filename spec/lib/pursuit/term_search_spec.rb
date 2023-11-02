# frozen_string_literal: true

RSpec.describe Pursuit::TermSearch do
  subject(:term_search) do
    described_class.new(
      Product.left_outer_joins(:variations).group(:id)
    ) do
      search_attribute :title
      search_attribute ProductVariation.arel_table[:title]
    end
  end

  describe '#initialize' do
    it 'is expected to set #relation eq `relation`' do
      expect(term_search).to have_attributes(relation: Product.left_outer_joins(:variations).group(:id))
    end

    it 'is expected to evaluate the passed block' do
      expect(term_search.attributes).to be_present
    end
  end

  describe '#parser' do
    subject(:parser) { term_search.parser }

    it { is_expected.to be_a(Pursuit::TermParser) }
  end

  describe '#transform' do
    subject(:transform) { term_search.transform }

    it { is_expected.to be_a(Pursuit::TermTransform) }
  end

  describe '#search_attribute' do
    subject(:search_attribute) do
      term_search.search_attribute(ProductVariation.arel_table[:currency])
    end

    it 'is expected to add the attribute to #attributes' do
      search_attribute
      expect(term_search.attributes).to include(ProductVariation.arel_table[:currency])
    end
  end

  describe '#parse' do
    subject(:parse) { term_search.parse('Shirt') }

    it 'is expected to equal the ARel node' do
      expect(parse).to eq(
        Product.arel_table[:title].matches('%Shirt%').or(
          ProductVariation.arel_table[:title].matches('%Shirt%')
        )
      )
    end
  end

  describe '#apply' do
    subject(:apply) { term_search.apply('Shirt') }

    it 'is expected to equal #relation with term clauses applied' do
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
