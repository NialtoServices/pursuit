# frozen_string_literal: true

RSpec.describe Pursuit::PredicateSearch do
  subject(:predicate_search) do
    described_class.new(
      Product.left_outer_joins(:variations).group(:id),
      permit_aggregate_modifiers: true
    ) do
      permit_attribute :title
      permit_attribute :variation, ProductVariation.arel_table[:id]
      permit_attribute :variation_title, ProductVariation.arel_table[:title]
    end
  end

  describe '#initialize' do
    it 'is expected to set #relation eq `relation`' do
      expect(predicate_search).to have_attributes(relation: Product.left_outer_joins(:variations).group(:id))
    end

    it 'is expected to set #permit_aggregate_modifiers eq `permit_aggregate_modifiers`' do
      expect(predicate_search).to have_attributes(permit_aggregate_modifiers: true)
    end

    it 'is expected to evaluate the passed block' do
      expect(predicate_search.permitted_attributes).to be_present
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

  describe '#permit_attribute' do
    subject(:permit_attribute) do
      predicate_search.permit_attribute(:variation_currency, ProductVariation.arel_table[:currency])
    end

    it 'is expected to add the attribute to #permitted_attributes' do
      permit_attribute
      expect(predicate_search.permitted_attributes).to match(
        hash_including(
          variation_currency: ProductVariation.arel_table[:currency]
        )
      )
    end
  end

  describe '#parse' do
    subject(:parse) { predicate_search.parse('title ~ Shirt & #variation > 0') }

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
    subject(:apply) { predicate_search.apply('title ~ Shirt') }

    it 'is expected to equal #relation with predicate clauses applied' do
      expect(apply).to eq(
        Product.left_outer_joins(:variations).group(:id).where(
          Product.arel_table[:title].matches('%Shirt%')
        )
      )
    end
  end
end
