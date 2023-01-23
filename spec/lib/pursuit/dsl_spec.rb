# frozen_string_literal: true

RSpec.describe Pursuit::DSL do
  subject(:record) { Product.new }

  describe '.search_options' do
    subject(:search_options) { record.class.search_options }

    it { is_expected.to be_a(Pursuit::SearchOptions) }
  end

  describe '.search' do
    subject(:search) { record.class.search('funky') }

    let(:product_a) { Product.create!(title: 'Plain Shirt') }
    let(:product_b) { Product.create!(title: 'Funky Shirt') }

    it 'is expected to return the matching records' do
      expect(search).to contain_exactly(product_b)
    end
  end
end
