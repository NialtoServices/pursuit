# frozen_string_literal: true

RSpec.describe Pursuit::PredicateSearch do
  subject(:predicate_search) do
    described_class.new(default_table: Product.arel_table, permit_aggregate_modifiers: true)
  end

  describe '#initialize' do
    it 'is expected to set #default_table eq `default_table`' do
      expect(predicate_search).to have_attributes(default_table: Product.arel_table)
    end

    it 'is expected to set #permit_aggregate_modifiers eq `permit_aggregate_modifiers`' do
      expect(predicate_search).to have_attributes(permit_aggregate_modifiers: true)
    end

    it 'is expected to invoke the passed block' do
      expect { |block| described_class.new(&block) }.to yield_control
    end
  end

  describe '#permit_attribute' do
    subject(:permit_attribute) { predicate_search.permit_attribute(name, attribute) }

    context 'when `attribute` is nil' do
      let(:name)      { :title }
      let(:attribute) { nil }

      it 'is expected to add the attribute from #default_table to #permitted_attributes' do
        permit_attribute
        expect(predicate_search.permitted_attributes).to match(
          hash_including(
            title: Product.arel_table[:title]
          )
        )
      end
    end

    context 'when `attribute` is a Symbol' do
      let(:name)      { :name }
      let(:attribute) { :title }

      it 'is expected to add the attribute from #default_table to #permitted_attributes' do
        permit_attribute
        expect(predicate_search.permitted_attributes).to match(
          hash_including(
            name: Product.arel_table[:title]
          )
        )
      end
    end

    context 'when `attribute` is an Arel::Attributes::Attribute' do
      let(:name)      { :variation_currency }
      let(:attribute) { ProductVariation.arel_table[:currency] }

      it 'is expected to add the attribute to #permitted_attributes' do
        permit_attribute
        expect(predicate_search.permitted_attributes).to match(
          hash_including(
            variation_currency: ProductVariation.arel_table[:currency]
          )
        )
      end
    end
  end

  describe '#parser' do
    subject(:parser) { predicate_search.parser }

    it { is_expected.to be_a(Pursuit::PredicateParser) }
  end

  describe '#transform' do
    subject(:transform) { predicate_search.transform }

    it { is_expected.to be_a(Pursuit::PredicateTransform) }
  end

  describe '#parse' do
    subject(:parse) { predicate_search.parse('title ~ Shirt & #variation > 0') }

    before do
      predicate_search.permitted_attributes[:title] = Product.arel_table[:title]
      predicate_search.permitted_attributes[:variation] = ProductVariation.arel_table[:id]
      predicate_search.permitted_attributes[:variation_title] = ProductVariation.arel_table[:title]
    end

    it 'is expected to equal a Hash containing the ARel nodes' do
      expect(parse).to eq(
        {
          where: Product.arel_table[:title].matches('%Shirt%'),
          having: ProductVariation.arel_table[:id].count.gt(0)
        }
      )
    end
  end

  describe '#apply' do
    subject(:apply) { predicate_search.apply('title ~ Shirt', Product.left_outer_joins(:variations).group(:id)) }

    before do
      predicate_search.permitted_attributes[:title] = Product.arel_table[:title]
      predicate_search.permitted_attributes[:variation] = ProductVariation.arel_table[:id]
      predicate_search.permitted_attributes[:variation_title] = ProductVariation.arel_table[:title]
    end

    it 'is expected to equal `relation` with predicate clauses applied' do
      expect(apply).to eq(
        Product.left_outer_joins(:variations).group(:id).where(
          Product.arel_table[:title].matches('%Shirt%')
        )
      )
    end
  end
end
