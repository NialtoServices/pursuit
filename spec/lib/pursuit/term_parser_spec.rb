# frozen_string_literal: true

RSpec.describe Pursuit::TermParser do
  subject(:parser) { described_class.new }

  describe '#space' do
    subject(:space) { parser.space }

    context 'when parsing an empty value' do
      subject(:parse) { space.parse('') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing one or more spaces' do
      subject(:parse) { space.parse(value) }

      let(:value) { ' ' * rand(1..10) }

      it 'is expected to eq the parsed spaces' do
        expect(parse).to eq(value)
      end
    end
  end

  describe '#space?' do
    subject(:space?) { parser.space? }

    context 'when parsing an empty value' do
      subject(:parse) { space?.parse('') }

      it 'is expected to eq the empty value' do
        expect(parse).to eq('')
      end
    end

    context 'when parsing one or more spaces' do
      subject(:parse) { space?.parse(value) }

      let(:value) { ' ' * rand(1..10) }

      it 'is expected to eq the parsed spaces' do
        expect(parse).to eq(value)
      end
    end
  end

  describe '#escaped_character' do
    subject(:escaped_character) { parser.escaped_character }

    context 'when parsing an escaped character' do
      subject(:parse) { escaped_character.parse('\\"') }

      it 'is expected to eq the escaped character' do
        expect(parse).to eq('\\"')
      end
    end

    context 'when parsing an unescaped character' do
      subject(:parse) { escaped_character.parse('"') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#string_double_quotes' do
    subject(:string_double_quotes) { parser.string_double_quotes }

    context 'when parsing a double quoted string' do
      subject(:parse) { string_double_quotes.parse('"Double \"Quoted\""') }

      it 'is expected to capture the contents of the double quotes as :string_double_quotes' do
        expect(parse).to eq(string_double_quotes: 'Double \"Quoted\"')
      end
    end

    context 'when parsing a single quoted string' do
      subject(:parse) { string_double_quotes.parse("'Single Quoted'") }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing an unquoted string' do
      subject(:parse) { string_double_quotes.parse('Unquoted') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#string_single_quotes' do
    subject(:string_single_quotes) { parser.string_single_quotes }

    context 'when parsing a single quoted string' do
      subject(:parse) { string_single_quotes.parse("'Single \\'Quoted\\''") }

      it 'is expected to capture the contents of the single quotes as :string_single_quotes' do
        expect(parse).to eq(string_single_quotes: "Single \\'Quoted\\'")
      end
    end

    context 'when parsing a double quoted string' do
      subject(:parse) { string_single_quotes.parse('"Double Quoted"') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing an unquoted string' do
      subject(:parse) { string_single_quotes.parse('Unquoted') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#string_no_quotes' do
    subject(:string_no_quotes) { parser.string_no_quotes }

    context 'when parsing an unquoted string with no spaces or symbols' do
      subject(:parse) { string_no_quotes.parse('Unquoted') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'Unquoted')
      end
    end

    context 'when parsing an unquoted string with spaces' do
      subject(:parse) { string_no_quotes.parse('No Quotes') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing an unquoted string with symbols' do
      subject(:parse) { string_no_quotes.parse('No:Quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'No:Quotes')
      end
    end
  end

  describe '#string' do
    subject(:string) { parser.string }

    context 'when parsing a double quoted string' do
      subject(:parse) { string.parse('"Double \"Quoted\""') }

      it 'is expected to capture the contents of the double quotes as :string_double_quotes' do
        expect(parse).to eq(string_double_quotes: 'Double \"Quoted\"')
      end
    end

    context 'when parsing a single quoted string' do
      subject(:parse) { string.parse("'Single \\'Quoted\\''") }

      it 'is expected to capture the contents of the single quotes as :string_single_quotes' do
        expect(parse).to eq(string_single_quotes: "Single \\'Quoted\\'")
      end
    end

    context 'when parsing an unquoted string' do
      subject(:parse) { string.parse('Unquoted') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'Unquoted')
      end
    end

    context 'when parsing an unquoted string with spaces' do
      subject(:parse) { string.parse('No Quotes') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing an unquoted string with symbols' do
      subject(:parse) { string.parse('a@b.c') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'a@b.c')
      end
    end
  end

  describe '#term' do
    subject(:term) { parser.term }

    context 'when parsing a string' do
      subject(:parse) { term.parse('Hello') }

      it 'is expected to capture the value as :term' do
        expect(parse).to match(hash_including(term: { string_no_quotes: 'Hello' }))
      end
    end
  end

  describe '#term_pair' do
    subject(:term_pair) { parser.term_pair }

    context 'when parsing a term' do
      subject(:parse) { term_pair.parse('Hello') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing two terms separated by a space' do
      subject(:parse) { term_pair.parse('Hello World') }

      it 'is expected to capture the first term as :left' do
        expect(parse).to match(hash_including(left: { term: { string_no_quotes: 'Hello' } }))
      end

      it 'is expected to capture the second term as :right' do
        expect(parse).to match(hash_including(right: { term: { string_no_quotes: 'World' } }))
      end
    end
  end

  describe '#term_node' do
    subject(:term_node) { parser.term_node }

    context 'when parsing a term' do
      subject(:parse) { term_node.parse('Hello') }

      it 'is expected to eq the term result' do
        expect(parse).to match(hash_including(term: { string_no_quotes: 'Hello' }))
      end
    end

    context 'when parsing multiple terms' do
      subject(:parse) { term_node.parse('Hello World') }

      it 'is expected to eq the term list result' do
        expect(parse).to match(
          hash_including(
            left: { term: { string_no_quotes: 'Hello' } },
            right: { term: { string_no_quotes: 'World' } }
          )
        )
      end
    end
  end

  describe '#terms' do
    subject(:terms) { parser.terms }

    context 'when parsing a complex list of terms' do
      subject(:parse) { terms.parse(" FirstTerm \"Second Term\" Third<>Term 'Fourth Term' ") }

      it 'is expected to eq the correct term tree' do
        expect(parse).to match(
          hash_including(
            left: { term: { string_no_quotes: 'FirstTerm' } },
            right: {
              left: { term: { string_double_quotes: 'Second Term' } },
              right: {
                left: { term: { string_no_quotes: 'Third<>Term' } },
                right: { term: { string_single_quotes: 'Fourth Term' } }
              }
            }
          )
        )
      end
    end
  end

  describe '#root' do
    subject(:root) { parser.root }

    it 'is expected to eq #terms' do
      expect(root).to eq(parser.terms)
    end
  end
end
