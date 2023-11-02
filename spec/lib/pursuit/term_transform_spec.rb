# frozen_string_literal: true

RSpec.describe Pursuit::TermTransform do
  subject(:transform) { described_class.new }

  describe '#apply' do
    subject(:apply) { transform.apply(tree, attributes: attributes) }

    let(:attributes) do
      [
        Product.arel_table[:title],
        ProductVariation.arel_table[:title]
      ].to_set
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

    context 'when passed a term' do
      let(:tree) do
        { term: { string_no_quotes: 'Shirt' } }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(
          Product.arel_table[:title].matches('%Shirt%').or(
            ProductVariation.arel_table[:title].matches('%Shirt%')
          )
        )
      end
    end

    context 'when passed multiple terms' do
      let(:tree) do
        {
          left: {
            term: { string_no_quotes: 'Shirt' }
          },
          right: {
            term: { string_no_quotes: 'Green' }
          }
        }
      end

      it 'is expected to equal the correct ARel node' do
        expect(apply).to eq(
          Product.arel_table[:title].matches('%Shirt%').or(
            ProductVariation.arel_table[:title].matches('%Shirt%')
          ).and(
            Product.arel_table[:title].matches('%Green%').or(
              ProductVariation.arel_table[:title].matches('%Green%')
            )
          )
        )
      end
    end
  end
end
