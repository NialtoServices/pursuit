# frozen_string_literal: true

RSpec.describe Pursuit::TermSearch do
  subject(:term_search) { described_class.new(default_table: Product.arel_table) }

  describe '#initialize' do
    it 'is expected to set #default_table eq `default_table`' do
      expect(term_search).to have_attributes(default_table: Product.arel_table)
    end

    it 'is expected to invoke the passed block' do
      expect { |block| described_class.new(&block) }.to yield_control
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
    subject(:search_attribute) { term_search.search_attribute(attribute) }

    context 'when `attribute` is a Symbol' do
      let(:attribute) { :title }

      it 'is expected to add the attribute from #default_table to #attributes' do
        search_attribute
        expect(term_search.attributes).to include(Product.arel_table[:title])
      end
    end

    context 'when `attribute` is an Arel::Attributes::Attribute' do
      let(:attribute) { ProductVariation.arel_table[:currency] }

      it 'is expected to add the attribute to #attributes' do
        search_attribute
        expect(term_search.attributes).to include(ProductVariation.arel_table[:currency])
      end
    end
  end

  describe '#parse' do
    subject(:parse) { term_search.parse('Shirt') }

    before do
      term_search.attributes << Product.arel_table[:title]
      term_search.attributes << ProductVariation.arel_table[:title]
    end

    it 'is expected to equal the ARel node' do
      expect(parse).to eq(
        Product.arel_table[:title].matches('%Shirt%').or(
          ProductVariation.arel_table[:title].matches('%Shirt%')
        )
      )
    end
  end

  describe '#apply' do
    subject(:apply) { term_search.apply('Shirt', Product.left_outer_joins(:variations).group(:id)) }

    before do
      term_search.attributes << Product.arel_table[:title]
      term_search.attributes << ProductVariation.arel_table[:title]
    end

    it 'is expected to equal `relation` with term clauses applied' do
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
