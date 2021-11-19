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

  describe '#record_class' do
    subject(:record_class) { search_options.record_class }

    it 'is expected to eq the class passed during initialization' do
      expect(record_class).to eq(Product)
    end
  end

  describe '#relations' do
    subject(:relations) { search_options.relations }

    before do
      search_options.relation :variations, :title, :stock_status
    end

    it 'is expected to contain the correct relations' do
      expect(relations).to eq(variations: %i[title stock_status])
    end
  end

  describe '#keyed_attributes' do
    subject(:keyed_attributes) { search_options.keyed_attributes }

    before do
      search_options.attribute :title, keyed: false
      search_options.attribute :title_length, &title_length_node_builder
      search_options.attribute :description
      search_options.attribute :rating, unkeyed: false
    end

    it 'is expected to contain the correct keyed attributes' do
      expect(keyed_attributes.keys).to contain_exactly(:title_length, :description, :rating)
    end

    it 'is expected to set a default node builder for attributes declared without a block' do
      expect(keyed_attributes[:description].call).to eq(Product.arel_table[:description])
    end

    it 'is expected to set a custom node builder for attributes declared with a block' do
      expect(keyed_attributes[:title_length]).to eq(title_length_node_builder)
    end
  end

  describe '#unkeyed_attributes' do
    subject(:unkeyed_attributes) { search_options.unkeyed_attributes }

    before do
      search_options.attribute :title, keyed: false
      search_options.attribute :title_length, &title_length_node_builder
      search_options.attribute :description
      search_options.attribute :rating, unkeyed: false
    end

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

  describe '#relation' do
    subject(:relation) { search_options.relation(:variations, :title, :stock_status) }

    it 'is expected to add the relation to #relations' do
      expect { relation }.to change(search_options, :relations).from({}).to(variations: %i[title stock_status])
    end
  end

  describe '#attribute' do
    subject(:attribute) { search_options.attribute(:description) }

    it { is_expected.to eq(nil) }

    it 'is expected to add the attribute to #attributes' do
      expect { attribute }.to change(search_options.attributes, :keys).from([]).to(%i[description])
    end

    it 'is expected to allow keyed searching by default' do
      attribute
      expect(search_options.attributes[:description].keyed).to eq(true)
    end

    it 'is expected to allow unkeyed searching by default' do
      attribute
      expect(search_options.attributes[:description].unkeyed).to eq(true)
    end

    it 'is expected to use the matching table column node builder by default' do
      attribute
      expect(search_options.attributes[:description].block.call).to eq(Product.arel_table[:description])
    end

    context 'when passing :keyed eq false' do
      subject(:attribute) { search_options.attribute(:description, keyed: false) }

      it 'is expected to disallow keyed searching' do
        attribute
        expect(search_options.attributes[:description].keyed).to eq(false)
      end
    end

    context 'when passing :unkeyed eq false' do
      subject(:attribute) { search_options.attribute(:description, unkeyed: false) }

      it 'is expected to disallow unkeyed searching' do
        attribute
        expect(search_options.attributes[:description].unkeyed).to eq(false)
      end
    end

    context 'when passing a block' do
      subject(:attribute) { search_options.attribute(:description, &title_length_node_builder) }

      it 'is expected to use the custom node builder' do
        attribute
        expect(search_options.attributes[:description].block).to eq(title_length_node_builder)
      end
    end
  end
end
