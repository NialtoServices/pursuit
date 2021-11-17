# frozen_string_literal: true

RSpec.describe Pursuit::TermParser do
  subject(:term_parser) { described_class.new(query, keys: keys) }

  let(:keys)  { %i[title description rating stock_status] }
  let(:query) do
    "plain title!='Socks' description*=\"green\" stock_status==in_stock shirt rating>=2 other*=thing rating<5"
  end

  describe '#unkeyed_term' do
    subject(:unkeyed_term) { term_parser.unkeyed_term }

    it 'is expected to eq the correct unkeyed term' do
      expect(unkeyed_term).to eq('plain shirt other*=thing')
    end
  end

  describe '#keyed_terms' do
    subject(:keyed_terms) { term_parser.keyed_terms }

    it 'is expected to eq the correct keyed terms' do
      expect(keyed_terms).to eq([
        Pursuit::TermParser::KeyedTerm.new('title', '!=', 'Socks'),
        Pursuit::TermParser::KeyedTerm.new('description', '*=', 'green'),
        Pursuit::TermParser::KeyedTerm.new('stock_status', '==', 'in_stock'),
        Pursuit::TermParser::KeyedTerm.new('rating', '>=', '2'),
        Pursuit::TermParser::KeyedTerm.new('rating', '<', '5')
      ])
    end
  end
end
