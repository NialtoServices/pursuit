# frozen_string_literal: true

RSpec.describe Pursuit::PredicateTransform do
  subject(:transform) { described_class.new }

  describe '#apply' do
    subject(:apply) do
      transform.apply(
        tree,
        permitted_attributes: permitted_attributes,
        permit_aggregate_modifiers: permit_aggregate_modifiers
      )
    end

    let(:permitted_attributes) do
      {
        title: Product.arel_table[:title],
        created_at: Product.arel_table[:created_at],
        updated_at: Product.arel_table[:updated_at],
        variations: ProductVariation.arel_table[Arel.star],
        variation_title: ProductVariation.arel_table[:title],
        variation_currency: ProductVariation.arel_table[:currency],
        variation_amount: ProductVariation.arel_table[:amount],
        variation_count: ProductVariation.arel_table[Arel.star].count
      }.with_indifferent_access
    end

    let(:permit_aggregate_modifiers) { true }

    context 'when passed a truthy tree' do
      let(:tree) do
        { truthy: 'true' }
      end

      it { is_expected.to be(true) }
    end

    context 'when passed a falsey tree' do
      let(:tree) do
        { falsey: 'false' }
      end

      it { is_expected.to be(false) }
    end

    context 'when passed an unsigned integer tree' do
      let(:tree) do
        { integer: '3' }
      end

      it { is_expected.to be_an(Integer) }

      it 'is expected to equal the correct integer value' do
        expect(apply).to eq(3)
      end
    end

    context 'when passed a signed integer tree' do
      let(:tree) do
        { integer: '-3' }
      end

      it { is_expected.to be_an(Integer) }

      it 'is expected to equal the correct integer value' do
        expect(apply).to eq(-3)
      end
    end

    context 'when passed an unsigned decimal tree' do
      let(:tree) do
        { decimal: '3.14' }
      end

      it { is_expected.to be_a(BigDecimal) }

      it 'is expected to equal the correct decimal value' do
        expect(apply).to eq(3.14)
      end
    end

    context 'when passed a signed decimal tree' do
      let(:tree) do
        { decimal: '-3.14' }
      end

      it { is_expected.to be_a(BigDecimal) }

      it 'is expected to equal the correct decimal value' do
        expect(apply).to eq(-3.14)
      end
    end

    context 'when passed an empty double quoted string' do
      let(:tree) do
        { string_double_quotes: [] }
      end

      it 'is expected to equal an empty string' do
        expect(apply).to eq('')
      end
    end

    context 'when passed a double quoted string' do
      let(:tree) do
        { string_double_quotes: 'Hello \\"World\\"' }
      end

      it 'is expected to equal the correct string' do
        expect(apply).to eq('Hello "World"')
      end
    end

    context 'when passed an empty single quoted string' do
      let(:tree) do
        { string_single_quotes: [] }
      end

      it 'is expected to equal an empty string' do
        expect(apply).to eq('')
      end
    end

    context 'when passed a single quoted string' do
      let(:tree) do
        { string_single_quotes: "Hello \\'World\\'" }
      end

      it 'is expected to equal the correct string' do
        expect(apply).to eq("Hello 'World'")
      end
    end

    context 'when passed an unquoted string' do
      let(:tree) do
        { string_no_quotes: 'hello_world' }
      end

      it 'is expected to equal the correct string' do
        expect(apply).to eq('hello_world')
      end
    end

    context 'when passed a comparison with the "=" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'title' },
          comparator: '=',
          value: { string_no_quotes: 'Shirt' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:title].eq('Shirt'))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            attribute: { string_no_quotes: 'title' },
            comparator: '=',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(
            Product.arel_table[:title].eq(nil).or(
              Product.arel_table[:title].matches_regexp('^\s*$')
            )
          )
        end
      end
    end

    context 'when passed a comparison with the "!=" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'title' },
          comparator: '!=',
          value: { string_no_quotes: 'Shirt' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:title].not_eq('Shirt'))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            attribute: { string_no_quotes: 'title' },
            comparator: '!=',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(
            Product.arel_table[:title].not_eq(nil).and(
              Product.arel_table[:title].does_not_match_regexp('^\s*$')
            )
          )
        end
      end
    end

    context 'when passed a comparison with the "<" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'created_at' },
          comparator: '<',
          value: { string_no_quotes: '1970-01-01' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:created_at].lt('1970-01-01'))
      end
    end

    context 'when passed a comparison with the ">" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'created_at' },
          comparator: '>',
          value: { string_no_quotes: '1970-01-01' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:created_at].gt('1970-01-01'))
      end
    end

    context 'when passed a comparison with the "<=" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'created_at' },
          comparator: '<=',
          value: { string_no_quotes: '1970-01-01' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:created_at].lteq('1970-01-01'))
      end
    end

    context 'when passed a comparison with the ">=" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'created_at' },
          comparator: '>=',
          value: { string_no_quotes: '1970-01-01' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:created_at].gteq('1970-01-01'))
      end
    end

    context 'when passed a comparison with the "~" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'title' },
          comparator: '~',
          value: { string_no_quotes: 'Shirt' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:title].matches('%Shirt%'))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            attribute: { string_no_quotes: 'title' },
            comparator: '~',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(Product.arel_table[:title].matches('%'))
        end
      end
    end

    context 'when passed a comparison with the "!~" comparator' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'title' },
          comparator: '!~',
          value: { string_no_quotes: 'Shirt' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(Product.arel_table[:title].does_not_match('%Shirt%'))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            attribute: { string_no_quotes: 'title' },
            comparator: '!~',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(Product.arel_table[:title].does_not_match('%'))
        end
      end
    end

    context 'when passed a comparison with an unpermitted attribute' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'id' },
          comparator: '=',
          value: { integer: '123' }
        }
      end

      it { expect { apply }.to raise_exception(Pursuit::AttributeNotFound) }
    end

    context 'when passed a comparison with an attribute representing "*"' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'variations' },
          comparator: '=',
          value: { integer: '123' }
        }
      end

      it { expect { apply }.to raise_exception(Pursuit::AggregateModifierRequired) }
    end

    context 'when passed a comparison with an attribute representing a custom node' do
      let(:tree) do
        {
          attribute: { string_no_quotes: 'variation_count' },
          comparator: '=',
          value: { integer: '123' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[Arel.star].count.eq(123))
      end
    end

    context 'when passed an aggregate comparison with the "=" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '*',
          attribute: { string_no_quotes: 'variation_amount' },
          comparator: '=',
          value: { integer: '5000' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:amount].sum.eq(5000))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            aggregate_modifier: '*',
            attribute: { string_no_quotes: 'variation_amount' },
            comparator: '=',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(
            ProductVariation.arel_table[:amount].sum.eq(nil).or(
              ProductVariation.arel_table[:amount].sum.matches_regexp('^\s*$')
            )
          )
        end
      end
    end

    context 'when passed an aggregate comparison with the "!=" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '*',
          attribute: { string_no_quotes: 'variation_amount' },
          comparator: '!=',
          value: { integer: '5000' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:amount].sum.not_eq(5000))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            aggregate_modifier: '*',
            attribute: { string_no_quotes: 'variation_amount' },
            comparator: '!=',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(
            ProductVariation.arel_table[:amount].sum.not_eq(nil).and(
              ProductVariation.arel_table[:amount].sum.does_not_match_regexp('^\s*$')
            )
          )
        end
      end
    end

    context 'when passed an aggregate comparison with the "<" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '-',
          attribute: { string_no_quotes: 'variation_amount' },
          comparator: '<',
          value: { integer: '1000' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:amount].minimum.lt(1000))
      end
    end

    context 'when passed an aggregate comparison with the ">" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '+',
          attribute: { string_no_quotes: 'variation_amount' },
          comparator: '>',
          value: { integer: '1000' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:amount].maximum.gt(1000))
      end
    end

    context 'when passed an aggregate comparison with the "<=" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '-',
          attribute: { string_no_quotes: 'variation_amount' },
          comparator: '<=',
          value: { integer: '1000' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:amount].minimum.lteq(1000))
      end
    end

    context 'when passed an aggregate comparison with the ">=" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '+',
          attribute: { string_no_quotes: 'variation_amount' },
          comparator: '>=',
          value: { integer: '1000' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:amount].maximum.gteq(1000))
      end
    end

    context 'when passed an aggregate comparison with the "~" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '~',
          attribute: { string_no_quotes: 'variation_currency' },
          comparator: '~',
          value: { string_no_quotes: 'USD' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:currency].average.matches('%USD%'))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            aggregate_modifier: '~',
            attribute: { string_no_quotes: 'variation_currency' },
            comparator: '~',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(ProductVariation.arel_table[:currency].average.matches('%'))
        end
      end
    end

    context 'when passed an aggregate comparison with the "!~" comparator' do
      let(:tree) do
        {
          aggregate_modifier: '~',
          attribute: { string_no_quotes: 'variation_currency' },
          comparator: '!~',
          value: { string_no_quotes: 'USD' }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(ProductVariation.arel_table[:currency].average.does_not_match('%USD%'))
      end

      context 'when the value is blank' do
        let(:tree) do
          {
            aggregate_modifier: '~',
            attribute: { string_no_quotes: 'variation_currency' },
            comparator: '!~',
            value: { string_single_quotes: [] }
          }
        end

        it 'is expected to equal the correct ARel node' do
          expect(apply).to eq(ProductVariation.arel_table[:currency].average.does_not_match('%'))
        end
      end
    end

    context 'when passed an aggregate comparison with an unpermitted attribute' do
      let(:tree) do
        {
          aggregate_modifier: '#',
          attribute: { string_no_quotes: 'variation_id' },
          comparator: '>',
          value: { integer: '0' }
        }
      end

      it { expect { apply }.to raise_exception(Pursuit::AttributeNotFound) }
    end

    context 'when passed an aggregate comparison with an unknown aggregate modifier' do
      let(:tree) do
        {
          aggregate_modifier: '!',
          attribute: { string_no_quotes: 'variations' },
          comparator: '>',
          value: { integer: '0' }
        }
      end

      it { expect { apply }.to raise_exception(Pursuit::AggregateModifierNotFound) }
    end

    context 'when passed an aggregate comparison with aggregate modifiers disabled' do
      let(:permit_aggregate_modifiers) { false }

      let(:tree) do
        {
          aggregate_modifier: '#',
          attribute: { string_no_quotes: 'variations' },
          comparator: '>',
          value: { integer: '0' }
        }
      end

      it { expect { apply }.to raise_exception(Pursuit::AggregateModifiersNotAvailable) }
    end

    context 'when passed a join using the "|" joiner' do
      let(:tree) do
        {
          left: {
            attribute: { string_no_quotes: 'title' },
            comparator: '=',
            value: { string_no_quotes: 'Shirt' }
          },
          joiner: '|',
          right: {
            attribute: { string_no_quotes: 'title' },
            comparator: '=',
            value: { string_no_quotes: 'Jumper' }
          }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(
          Product.arel_table[:title].eq('Shirt').or(
            Product.arel_table[:title].eq('Jumper')
          )
        )
      end
    end

    context 'when passed a join using the "&" joiner' do
      let(:tree) do
        {
          left: {
            attribute: { string_no_quotes: 'title' },
            comparator: '~',
            value: { string_no_quotes: 'Shirt' }
          },
          joiner: '&',
          right: {
            attribute: { string_no_quotes: 'title' },
            comparator: '~',
            value: { string_no_quotes: 'Green' }
          }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(
          Product.arel_table[:title].matches('%Shirt%').and(
            Product.arel_table[:title].matches('%Green%')
          )
        )
      end
    end
  end
end
