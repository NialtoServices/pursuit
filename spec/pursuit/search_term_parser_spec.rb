# frozen_string_literal: true

RSpec.describe Pursuit::SearchTermParser do
  subject(:parser) { described_class.new(query, keys: keys) }

  let(:keys) { %w[title description rating stock_status] }
  let(:query) do
    "plain title!='Socks' description*=\"green\" stock_status==in_stock shirt rating>=2 other*=thing rating<5"
  end

  describe '#unkeyed_term' do
    subject(:unkeyed_term) { parser.unkeyed_term }

    it 'is expected to eq the correct unkeyed term' do
      expect(unkeyed_term).to eq('plain shirt other*=thing')
    end
  end

  describe '#keyed_terms' do
    subject(:keyed_terms) { parser.keyed_terms }

    it 'is expected to eq the correct keyed terms' do
      expect(keyed_terms).to eq([
        Pursuit::SearchTermParser::KeyedTerm.new('title', '!=', 'Socks'),
        Pursuit::SearchTermParser::KeyedTerm.new('description', '*=', 'green'),
        Pursuit::SearchTermParser::KeyedTerm.new('stock_status', '==', 'in_stock'),
        Pursuit::SearchTermParser::KeyedTerm.new('rating', '>=', '2'),
        Pursuit::SearchTermParser::KeyedTerm.new('rating', '<', '5')
      ])
    end
  end
end
