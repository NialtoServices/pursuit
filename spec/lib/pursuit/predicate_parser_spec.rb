# frozen_string_literal: true

RSpec.describe Pursuit::PredicateParser do
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

  describe '#boolean_true' do
    subject(:boolean_true) { parser.boolean_true }

    context 'when parsing "true"' do
      subject(:parse) { boolean_true.parse('true') }

      it 'is expected to capture the value as :truthy' do
        expect(parse).to eq(truthy: 'true')
      end
    end

    context 'when parsing "True"' do
      subject(:parse) { boolean_true.parse('True') }

      it 'is expected to capture the value as :truthy' do
        expect(parse).to eq(truthy: 'True')
      end
    end

    context 'when parsing "TRUE"' do
      subject(:parse) { boolean_true.parse('TRUE') }

      it 'is expected to capture the value as :truthy' do
        expect(parse).to eq(truthy: 'TRUE')
      end
    end

    context 'when parsing "t"' do
      subject(:parse) { boolean_true.parse('t') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "yes"' do
      subject(:parse) { boolean_true.parse('yes') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "1"' do
      subject(:parse) { boolean_true.parse('1') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#boolean_false' do
    subject(:boolean_false) { parser.boolean_false }

    context 'when parsing "false"' do
      subject(:parse) { boolean_false.parse('false') }

      it 'is expected to capture the value as :falsey' do
        expect(parse).to eq(falsey: 'false')
      end
    end

    context 'when parsing "False"' do
      subject(:parse) { boolean_false.parse('False') }

      it 'is expected to capture the value as :falsey' do
        expect(parse).to eq(falsey: 'False')
      end
    end

    context 'when parsing "FALSE"' do
      subject(:parse) { boolean_false.parse('FALSE') }

      it 'is expected to capture the value as :falsey' do
        expect(parse).to eq(falsey: 'FALSE')
      end
    end

    context 'when parsing "f"' do
      subject(:parse) { boolean_false.parse('f') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "no"' do
      subject(:parse) { boolean_false.parse('no') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "0"' do
      subject(:parse) { boolean_false.parse('0') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#boolean' do
    subject(:boolean) { parser.boolean }

    context 'when parsing "true"' do
      subject(:parse) { boolean.parse('true') }

      it 'is expected to capture the value as :truthy' do
        expect(parse).to eq(truthy: 'true')
      end
    end

    context 'when parsing "false"' do
      subject(:parse) { boolean.parse('false') }

      it 'is expected to capture the value as :falsey' do
        expect(parse).to eq(falsey: 'false')
      end
    end

    context 'when parsing a non-boolean value' do
      subject(:parse) { boolean.parse('not-a-boolean') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#integer' do
    subject(:integer) { parser.integer }

    context 'when parsing one or more digits' do
      subject(:parse) { integer.parse(value) }

      let(:value) { rand(0..999_999).to_s }

      it 'is expected to capture the value as :integer' do
        expect(parse).to eq(integer: value)
      end
    end

    context 'when parsing one or more digits prefixed with "+"' do
      subject(:parse) { integer.parse(value) }

      let(:value) { format('+%<value>d', value: rand(0..999_999)) }

      it 'is expected to capture the value as :integer' do
        expect(parse).to eq(integer: value)
      end
    end

    context 'when parsing one or more digits prefixed with "-"' do
      subject(:parse) { integer.parse(value) }

      let(:value) { format('-%<value>d', value: rand(0..999_999)) }

      it 'is expected to capture the value as :integer' do
        expect(parse).to eq(integer: value)
      end
    end

    context 'when parsing digits separated by "."' do
      subject(:parse) { integer.parse(value) }

      let(:value) { rand(10.0...11.0).to_s }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing a non-numeric value' do
      subject(:parse) { integer.parse('one') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#decimal' do
    subject(:decimal) { parser.decimal }

    context 'when parsing digits separated by "."' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { rand(0.0...999_999.0).to_s }

      it 'is expected to capture the value as :decimal' do
        expect(parse).to eq(decimal: value)
      end
    end

    context 'when parsing digits separated by "." and prefixed with "+"' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { format('+%<value>f', value: rand(0.0...999_999.0)) }

      it 'is expected to capture the value as :decimal' do
        expect(parse).to eq(decimal: value)
      end
    end

    context 'when parsing digits separated by "." and prefixed with "-"' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { format('-%<value>f', value: rand(0.0...999_999.0)) }

      it 'is expected to capture the value as :decimal' do
        expect(parse).to eq(decimal: value)
      end
    end

    context 'when parsing digits prefixed with "."' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { format('.%<value>d', value: rand(0...10)) }

      it 'is expected to capture the value as :decimal' do
        expect(parse).to eq(decimal: value)
      end
    end

    context 'when parsing digits prefixed with "+."' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { format('+.%<value>d', value: rand(0...10)) }

      it 'is expected to capture the value as :decimal' do
        expect(parse).to eq(decimal: value)
      end
    end

    context 'when parsing digits prefixed with "-."' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { format('-.%<value>d', value: rand(0...10)) }

      it 'is expected to capture the value as :decimal' do
        expect(parse).to eq(decimal: value)
      end
    end

    context 'when parsing digits suffixed with "."' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { format('%<value>d.', value: rand(0...10)) }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing digits separated by "." more than once' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { format('%<a>d.%<b>d.%<c>d', a: rand(0...10), b: rand(0...10), c: rand(0...10)) }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing digits not separated by "."' do
      subject(:parse) { decimal.parse(value) }

      let(:value) { rand(0...10).to_s }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing a non-numeric value' do
      subject(:parse) { decimal.parse('one') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#number' do
    subject(:number) { parser.number }

    context 'when parsing digits separated by "."' do
      subject(:parse) { number.parse(value) }

      let(:value) { rand(0.0...999_999.0).to_s }

      it 'is expected to capture the value as :decimal' do
        expect(parse).to eq(decimal: value)
      end
    end

    context 'when parsing digits not separated by "."' do
      subject(:parse) { number.parse(value) }

      let(:value) { rand(0..999_999).to_s }

      it 'is expected to capture the value as :integer' do
        expect(parse).to eq(integer: value)
      end
    end

    context 'when parsing a non-numeric value' do
      subject(:parse) { number.parse('one') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
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

    context 'when parsing an unquoted string with unsupported symbols' do
      subject(:parse) { string_no_quotes.parse('No&Quotes') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing an unquoted string with the "_" symbol' do
      subject(:parse) { string_no_quotes.parse('no_quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no_quotes')
      end
    end

    context 'when parsing an unquoted string with the "!" symbol' do
      subject(:parse) { string_no_quotes.parse('no!quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no!quotes')
      end
    end

    context 'when parsing an unquoted string with the "\'" character' do
      subject(:parse) { string_no_quotes.parse("no'quotes") }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: "no'quotes")
      end
    end

    context 'when parsing an unquoted string with the "+" character' do
      subject(:parse) { string_no_quotes.parse('no+quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no+quotes')
      end
    end

    context 'when parsing an unquoted string with the "," character' do
      subject(:parse) { string_no_quotes.parse('no,quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no,quotes')
      end
    end

    context 'when parsing an unquoted string with the "-" character' do
      subject(:parse) { string_no_quotes.parse('no-quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no-quotes')
      end
    end

    context 'when parsing an unquoted string with the "." character' do
      subject(:parse) { string_no_quotes.parse('no.quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no.quotes')
      end
    end

    context 'when parsing an unquoted string with the "/" character' do
      subject(:parse) { string_no_quotes.parse('no/quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no/quotes')
      end
    end

    context 'when parsing an unquoted string with the ":" character' do
      subject(:parse) { string_no_quotes.parse('no:quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no:quotes')
      end
    end

    context 'when parsing an unquoted string with the "?" character' do
      subject(:parse) { string_no_quotes.parse('no?quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no?quotes')
      end
    end

    context 'when parsing an unquoted string with the "@" character' do
      subject(:parse) { string_no_quotes.parse('no@quotes') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq(string_no_quotes: 'no@quotes')
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

  describe '#operator_equal' do
    subject(:operator_equal) { parser.operator_equal }

    context 'when parsing "="' do
      subject(:parse) { operator_equal.parse('=') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('=')
      end
    end
  end

  describe '#operator_not_equal' do
    subject(:operator_not_equal) { parser.operator_not_equal }

    context 'when parsing "!="' do
      subject(:parse) { operator_not_equal.parse('!=') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('!=')
      end
    end
  end

  describe '#operator_contains' do
    subject(:operator_contains) { parser.operator_contains }

    context 'when parsing "~"' do
      subject(:parse) { operator_contains.parse('~') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('~')
      end
    end
  end

  describe '#operator_not_contains' do
    subject(:operator_not_contains) { parser.operator_not_contains }

    context 'when parsing "!~"' do
      subject(:parse) { operator_not_contains.parse('!~') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('!~')
      end
    end
  end

  describe '#operator_less_than' do
    subject(:operator_less_than) { parser.operator_less_than }

    context 'when parsing "<"' do
      subject(:parse) { operator_less_than.parse('<') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('<')
      end
    end
  end

  describe '#operator_greater_than' do
    subject(:operator_greater_than) { parser.operator_greater_than }

    context 'when parsing ">"' do
      subject(:parse) { operator_greater_than.parse('>') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('>')
      end
    end
  end

  describe '#operator_less_than_or_equal_to' do
    subject(:operator_less_than_or_equal_to) { parser.operator_less_than_or_equal_to }

    context 'when parsing "<="' do
      subject(:parse) { operator_less_than_or_equal_to.parse('<=') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('<=')
      end
    end
  end

  describe '#operator_greater_than_or_equal_to' do
    subject(:operator_greater_than_or_equal_to) { parser.operator_greater_than_or_equal_to }

    context 'when parsing ">="' do
      subject(:parse) { operator_greater_than_or_equal_to.parse('>=') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('>=')
      end
    end
  end

  describe '#operator_and' do
    subject(:operator_and) { parser.operator_and }

    context 'when parsing "&"' do
      subject(:parse) { operator_and.parse('&') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('&')
      end
    end
  end

  describe '#operator_or' do
    subject(:operator_or) { parser.operator_or }

    context 'when parsing "|"' do
      subject(:parse) { operator_or.parse('|') }

      it 'is expected to eq the parsed value' do
        expect(parse).to eq('|')
      end
    end
  end

  describe '#comparator' do
    subject(:comparator) { parser.comparator }

    context 'when parsing "="' do
      subject(:parse) { comparator.parse('=') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '=')
      end
    end

    context 'when parsing "!="' do
      subject(:parse) { comparator.parse('!=') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '!=')
      end
    end

    context 'when parsing "~"' do
      subject(:parse) { comparator.parse('~') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '~')
      end
    end

    context 'when parsing "!~"' do
      subject(:parse) { comparator.parse('!~') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '!~')
      end
    end

    context 'when parsing "<"' do
      subject(:parse) { comparator.parse('<') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '<')
      end
    end

    context 'when parsing ">"' do
      subject(:parse) { comparator.parse('>') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '>')
      end
    end

    context 'when parsing "<="' do
      subject(:parse) { comparator.parse('<=') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '<=')
      end
    end

    context 'when parsing ">="' do
      subject(:parse) { comparator.parse('>=') }

      it 'is expected to capture the value as :operator' do
        expect(parse).to eq(comparator: '>=')
      end
    end

    context 'when parsing "&"' do
      subject(:parse) { comparator.parse('&') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "|"' do
      subject(:parse) { comparator.parse('|') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#joiner' do
    subject(:joiner) { parser.joiner }

    context 'when parsing "&"' do
      subject(:parse) { joiner.parse('&') }

      it 'is expected to capture the value as :join' do
        expect(parse).to eq(joiner: '&')
      end
    end

    context 'when parsing "|"' do
      subject(:parse) { joiner.parse('|') }

      it 'is expected to capture the value as :join' do
        expect(parse).to eq(joiner: '|')
      end
    end

    context 'when parsing "="' do
      subject(:parse) { joiner.parse('=') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "!="' do
      subject(:parse) { joiner.parse('!=') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "~"' do
      subject(:parse) { joiner.parse('~') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "!~"' do
      subject(:parse) { joiner.parse('!~') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "<"' do
      subject(:parse) { joiner.parse('<') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing ">"' do
      subject(:parse) { joiner.parse('>') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing "<="' do
      subject(:parse) { joiner.parse('<=') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing ">="' do
      subject(:parse) { joiner.parse('>=') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#aggregate_modifier' do
    subject(:aggregate_modifier) { parser.aggregate_modifier }

    context 'when parsing "#"' do
      subject(:parse) { aggregate_modifier.parse('#') }

      it 'is expected to capture the value as :aggregate_modifier' do
        expect(parse).to eq(aggregate_modifier: '#')
      end
    end

    context 'when parsing "*"' do
      subject(:parse) { aggregate_modifier.parse('*') }

      it 'is expected to capture the value as :aggregate_modifier' do
        expect(parse).to eq(aggregate_modifier: '*')
      end
    end

    context 'when parsing "+"' do
      subject(:parse) { aggregate_modifier.parse('+') }

      it 'is expected to capture the value as :aggregate_modifier' do
        expect(parse).to eq(aggregate_modifier: '+')
      end
    end

    context 'when parsing "-"' do
      subject(:parse) { aggregate_modifier.parse('-') }

      it 'is expected to capture the value as :aggregate_modifier' do
        expect(parse).to eq(aggregate_modifier: '-')
      end
    end

    context 'when parsing "~"' do
      subject(:parse) { aggregate_modifier.parse('~') }

      it 'is expected to capture the value as :aggregate_modifier' do
        expect(parse).to eq(aggregate_modifier: '~')
      end
    end
  end

  describe '#attribute' do
    subject(:attribute) { parser.attribute }

    context 'when parsing a double quoted string' do
      subject(:parse) { attribute.parse('"First Name"') }

      it 'is expected to capture the value as :attribute' do
        expect(parse).to match(hash_including(attribute: { string_double_quotes: 'First Name' }))
      end
    end

    context 'when parsing a single quoted string' do
      subject(:parse) { attribute.parse("'First Name'") }

      it 'is expected to capture the value as :attribute' do
        expect(parse).to match(hash_including(attribute: { string_single_quotes: 'First Name' }))
      end
    end

    context 'when parsing an unquoted string' do
      subject(:parse) { attribute.parse('first_name') }

      it 'is expected to capture the value as :attribute' do
        expect(parse).to match(hash_including(attribute: { string_no_quotes: 'first_name' }))
      end
    end

    context 'when parsing an unquoted string with spaces' do
      subject(:parse) { attribute.parse('first name') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#value' do
    subject(:value) { parser.value }

    context 'when parsing a boolean' do
      subject(:parse) { value.parse('true') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { truthy: 'true' })
      end
    end

    context 'when parsing a whole number' do
      subject(:parse) { value.parse('123') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { integer: '123' })
      end
    end

    context 'when parsing a decimal number' do
      subject(:parse) { value.parse('123.456') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { decimal: '123.456' })
      end
    end

    context 'when parsing a double quoted string' do
      subject(:parse) { value.parse('"Double Quoted"') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { string_double_quotes: 'Double Quoted' })
      end
    end

    context 'when parsing a single quoted string' do
      subject(:parse) { value.parse("'Single Quoted'") }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { string_single_quotes: 'Single Quoted' })
      end
    end

    context 'when parsing an unquoted string' do
      subject(:parse) { value.parse('Unquoted') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { string_no_quotes: 'Unquoted' })
      end
    end

    context 'when parsing an unquoted string that starts with a number' do
      subject(:parse) { value.parse('1a') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { string_no_quotes: '1a' })
      end
    end

    context 'when parsing an unquoted string that starts with "true"' do
      subject(:parse) { value.parse('trueness') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { string_no_quotes: 'trueness' })
      end
    end

    context 'when parsing an unquoted string with spaces' do
      subject(:parse) { value.parse('No Quotes') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end

    context 'when parsing an unquoted string with symbols' do
      subject(:parse) { value.parse('a@b.c') }

      it 'is expected to capture the value as :value' do
        expect(parse).to eq(value: { string_no_quotes: 'a@b.c' })
      end
    end
  end

  describe '#comparison' do
    subject(:comparison) { parser.comparison }

    context 'when parsing a comparison without an aggregate modifier' do
      subject(:parse) { comparison.parse('rating > 3') }

      it 'is expected to capture the attribute as :attribute' do
        expect(parse).to match(hash_including(attribute: { string_no_quotes: 'rating' }))
      end

      it 'is expected to capture the comparator as :comparator' do
        expect(parse).to match(hash_including(comparator: '>'))
      end

      it 'is expected to capture the value as :value' do
        expect(parse).to match(hash_including(value: { integer: '3' }))
      end
    end

    context 'when parsing a comparison with an aggregate modifier' do
      subject(:parse) { comparison.parse('#variants >= 5') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#comparison_group' do
    subject(:comparison_group) { parser.comparison_group }

    context 'when parsing a comparison with brackets' do
      subject(:parse) { comparison_group.parse('(title = Shirt)') }

      it 'is expected to eq the comparison result' do
        expect(parse).to eq(
          attribute: { string_no_quotes: 'title' },
          comparator: '=',
          value: { string_no_quotes: 'Shirt' }
        )
      end
    end

    context 'when parsing a nested group' do
      subject(:parse) { comparison_group.parse('((title = Shirt))') }

      it 'is expected to eq the nested group result' do
        expect(parse).to eq(
          attribute: { string_no_quotes: 'title' },
          comparator: '=',
          value: { string_no_quotes: 'Shirt' }
        )
      end
    end

    context 'when parsing a join' do
      subject(:parse) { comparison_group.parse('(title = Shirt | title = T-Shirt)') }

      it 'is expected to eq the join result' do
        expect(parse).to eq(
          left: {
            attribute: { string_no_quotes: 'title' },
            comparator: '=',
            value: { string_no_quotes: 'Shirt' }
          },
          joiner: '|',
          right: {
            attribute: { string_no_quotes: 'title' },
            comparator: '=',
            value: { string_no_quotes: 'T-Shirt' }
          }
        )
      end
    end

    context 'when parsing a comparison without brackets' do
      subject(:parse) { comparison_group.parse('title = Shirt') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#comparison_join' do
    subject(:comparison_join) { parser.comparison_join }

    context 'when parsing a join of two comparisons' do
      subject(:parse) { comparison_join.parse('title = Shirt | title = T-Shirt') }

      it 'is expected to capture the left comparison as :left' do
        expect(parse).to match(
          hash_including(
            left: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'Shirt' }
            }
          )
        )
      end

      it 'is expected to capture the joiner as :joiner' do
        expect(parse).to match(hash_including(joiner: '|'))
      end

      it 'is expected to capture the right comparison as :right' do
        expect(parse).to match(
          hash_including(
            right: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'T-Shirt' }
            }
          )
        )
      end
    end

    context 'when parsing a join of a comparison to another join' do
      subject(:parse) { comparison_join.parse('rating >= 3 & title = Shirt | title = T-Shirt') }

      it 'is expected to capture the left comparison as :left' do
        expect(parse).to match(
          hash_including(
            left: {
              attribute: { string_no_quotes: 'rating' },
              comparator: '>=',
              value: { integer: '3' }
            }
          )
        )
      end

      it 'is expected to capture the joiner as :joiner' do
        expect(parse).to match(hash_including(joiner: '&'))
      end

      it 'is expected to capture the right join as :right' do
        expect(parse).to match(
          hash_including(
            right: {
              left: {
                attribute: { string_no_quotes: 'title' },
                comparator: '=',
                value: { string_no_quotes: 'Shirt' }
              },
              joiner: '|',
              right: {
                attribute: { string_no_quotes: 'title' },
                comparator: '=',
                value: { string_no_quotes: 'T-Shirt' }
              }
            }
          )
        )
      end
    end
  end

  describe '#comparison_node' do
    subject(:comparison_node) { parser.comparison_node }

    context 'when parsing a comparison' do
      subject(:parse) { comparison_node.parse('rating >= 3') }

      it 'is expected to eq the comparison result' do
        expect(parse).to match(
          hash_including(
            attribute: { string_no_quotes: 'rating' },
            comparator: '>=',
            value: { integer: '3' }
          )
        )
      end
    end

    context 'when parsing a join' do
      subject(:parse) { comparison_node.parse('title = Shirt | title = T-Shirt') }

      it 'is expected to eq the join result' do
        expect(parse).to match(
          hash_including(
            left: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'Shirt' }
            },
            joiner: '|',
            right: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'T-Shirt' }
            }
          )
        )
      end
    end

    context 'when parsing a group' do
      subject(:parse) { comparison_node.parse('(title = Shirt)') }

      it 'is expected to eq the group result' do
        expect(parse).to match(
          hash_including(
            attribute: { string_no_quotes: 'title' },
            comparator: '=',
            value: { string_no_quotes: 'Shirt' }
          )
        )
      end
    end
  end

  describe '#aggregate_comparison' do
    subject(:aggregate_comparison) { parser.aggregate_comparison }

    context 'when parsing a comparison with an aggregate modifier' do
      subject(:parse) { aggregate_comparison.parse('#variations >= 5') }

      it 'is expected to capture the aggregate modifier as :aggregate_modifier' do
        expect(parse).to match(hash_including(aggregate_modifier: '#'))
      end

      it 'is expected to capture the attribute as :attribute' do
        expect(parse).to match(hash_including(attribute: { string_no_quotes: 'variations' }))
      end

      it 'is expected to capture the comparator as :comparator' do
        expect(parse).to match(hash_including(comparator: '>='))
      end

      it 'is expected to capture the value as :value' do
        expect(parse).to match(hash_including(value: { integer: '5' }))
      end
    end

    context 'when parsing a comparison without an aggregate modifier' do
      subject(:parse) { aggregate_comparison.parse('rating > 3') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#aggregate_comparison_group' do
    subject(:aggregate_comparison_group) { parser.aggregate_comparison_group }

    context 'when parsing an aggregate comparison with brackets' do
      subject(:parse) { aggregate_comparison_group.parse('(#variations >= 5)') }

      it 'is expected to eq the comparison result' do
        expect(parse).to eq(
          aggregate_modifier: '#',
          attribute: { string_no_quotes: 'variations' },
          comparator: '>=',
          value: { integer: '5' }
        )
      end
    end

    context 'when parsing a nested group' do
      subject(:parse) { aggregate_comparison_group.parse('((#variations >= 5))') }

      it 'is expected to eq the nested comparison group result' do
        expect(parse).to eq(
          aggregate_modifier: '#',
          attribute: { string_no_quotes: 'variations' },
          comparator: '>=',
          value: { integer: '5' }
        )
      end
    end

    context 'when parsing a join' do
      subject(:parse) { aggregate_comparison_group.parse('(#variations >= 5 | #variations = 1)') }

      it 'is expected to eq the aggregate comparison join result' do
        expect(parse).to eq(
          left: {
            aggregate_modifier: '#',
            attribute: { string_no_quotes: 'variations' },
            comparator: '>=',
            value: { integer: '5' }
          },
          joiner: '|',
          right: {
            aggregate_modifier: '#',
            attribute: { string_no_quotes: 'variations' },
            comparator: '=',
            value: { integer: '1' }
          }
        )
      end
    end

    context 'when parsing an aggregate comparison without brackets' do
      subject(:parse) { aggregate_comparison_group.parse('#variations >= 5') }

      it { expect { parse }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe '#aggregate_comparison_join' do
    subject(:aggregate_comparison_join) { parser.aggregate_comparison_join }

    context 'when parsing a join of two aggregate comparisons' do
      subject(:parse) { aggregate_comparison_join.parse('#variations >= 5 | #variations = 1') }

      it 'is expected to capture the left comparison as :left' do
        expect(parse).to match(
          hash_including(
            left: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '>=',
              value: { integer: '5' }
            }
          )
        )
      end

      it 'is expected to capture the joiner as :joiner' do
        expect(parse).to match(hash_including(joiner: '|'))
      end

      it 'is expected to capture the right comparison as :right' do
        expect(parse).to match(
          hash_including(
            right: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '=',
              value: { integer: '1' }
            }
          )
        )
      end
    end

    context 'when parsing a join of an aggregate comparison to another join' do
      subject(:parse) { aggregate_comparison_join.parse('*views > 100 & #variations >= 5 | #variations = 1') }

      it 'is expected to capture the left aggregate comparison as :left' do
        expect(parse).to match(
          hash_including(
            left: {
              aggregate_modifier: '*',
              attribute: { string_no_quotes: 'views' },
              comparator: '>',
              value: { integer: '100' }
            }
          )
        )
      end

      it 'is expected to capture the joiner as :joiner' do
        expect(parse).to match(hash_including(joiner: '&'))
      end

      it 'is expected to capture the right join as :right' do
        expect(parse).to match(
          hash_including(
            right: {
              left: {
                aggregate_modifier: '#',
                attribute: { string_no_quotes: 'variations' },
                comparator: '>=',
                value: { integer: '5' }
              },
              joiner: '|',
              right: {
                aggregate_modifier: '#',
                attribute: { string_no_quotes: 'variations' },
                comparator: '=',
                value: { integer: '1' }
              }
            }
          )
        )
      end
    end
  end

  describe '#aggregate_comparison_node' do
    subject(:aggregate_comparison_node) { parser.aggregate_comparison_node }

    context 'when parsing an aggregate comparison' do
      subject(:parse) { aggregate_comparison_node.parse('#variations >= 5') }

      it 'is expected to eq the aggregate comparison result' do
        expect(parse).to match(
          hash_including(
            aggregate_modifier: '#',
            attribute: { string_no_quotes: 'variations' },
            comparator: '>=',
            value: { integer: '5' }
          )
        )
      end
    end

    context 'when parsing a join' do
      subject(:parse) { aggregate_comparison_node.parse('#variations >= 5 | #variations = 1') }

      it 'is expected to eq the join result' do
        expect(parse).to match(
          hash_including(
            left: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '>=',
              value: { integer: '5' }
            },
            joiner: '|',
            right: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '=',
              value: { integer: '1' }
            }
          )
        )
      end
    end

    context 'when parsing a group' do
      subject(:parse) { aggregate_comparison_node.parse('(#variations >= 5)') }

      it 'is expected to eq the group result' do
        expect(parse).to match(
          hash_including(
            aggregate_modifier: '#',
            attribute: { string_no_quotes: 'variations' },
            comparator: '>=',
            value: { integer: '5' }
          )
        )
      end
    end
  end

  describe '#predicate_where' do
    subject(:predicate_where) { parser.predicate_where }

    context 'when parsing a comparison' do
      subject(:parse) { predicate_where.parse('title = Shirt') }

      it 'is expected to capture the comparison as :where' do
        expect(parse).to match(
          hash_including(
            where: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'Shirt' }
            }
          )
        )
      end
    end
  end

  describe '#predicate_having' do
    subject(:predicate_having) { parser.predicate_having }

    context 'when parsing an aggregate comparison' do
      subject(:parse) { predicate_having.parse('#variations >= 5') }

      it 'is expected to capture the aggregate comparison as :having' do
        expect(parse).to match(
          hash_including(
            having: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '>=',
              value: { integer: '5' }
            }
          )
        )
      end
    end
  end

  describe '#predicate' do
    subject(:predicate) { parser.predicate }

    context 'when parsing a comparison' do
      subject(:parse) { predicate.parse('title = Shirt') }

      it 'is expected to capture the comparison as :where' do
        expect(parse).to match(
          hash_including(
            where: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'Shirt' }
            }
          )
        )
      end
    end

    context 'when parsing an aggregate comparison' do
      subject(:parse) { predicate.parse('#variations >= 5') }

      it 'is expected to capture the aggregate comparison as :having' do
        expect(parse).to match(
          hash_including(
            having: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '>=',
              value: { integer: '5' }
            }
          )
        )
      end
    end

    context 'when parsing a comparison followed by an aggregate comparison' do
      subject(:parse) { predicate.parse('title = Shirt & #variations >= 5') }

      it 'is expected to capture the comparison as :where' do
        expect(parse).to match(
          hash_including(
            where: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'Shirt' }
            }
          )
        )
      end

      it 'is expected to capture the aggregate comparison as :having' do
        expect(parse).to match(
          hash_including(
            having: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '>=',
              value: { integer: '5' }
            }
          )
        )
      end
    end

    context 'when parsing an aggregate comparison followed by a comparison' do
      subject(:parse) { predicate.parse('#variations >= 5 & title = Shirt') }

      it 'is expected to capture the comparison as :where' do
        expect(parse).to match(
          hash_including(
            where: {
              attribute: { string_no_quotes: 'title' },
              comparator: '=',
              value: { string_no_quotes: 'Shirt' }
            }
          )
        )
      end

      it 'is expected to capture the aggregate comparison as :having' do
        expect(parse).to match(
          hash_including(
            having: {
              aggregate_modifier: '#',
              attribute: { string_no_quotes: 'variations' },
              comparator: '>=',
              value: { integer: '5' }
            }
          )
        )
      end
    end

    context 'when parsing a complex query' do
      subject(:parse) do
        predicate.parse(' title ~ "Polo Shirts" & (rating > 2.5 | featured = true) & #variations >= 5 ')
      end

      it 'is expected to eq the correct tree' do # rubocop:disable RSpec/ExampleLength
        expect(parse).to eq(
          where: {
            left: {
              attribute: { string_no_quotes: 'title' },
              comparator: '~',
              value: { string_double_quotes: 'Polo Shirts' }
            },
            joiner: '&',
            right: {
              left: {
                attribute: { string_no_quotes: 'rating' },
                comparator: '>',
                value: { decimal: '2.5' }
              },
              joiner: '|',
              right: {
                attribute: { string_no_quotes: 'featured' },
                comparator: '=',
                value: { truthy: 'true' }
              }
            }
          },
          having: {
            aggregate_modifier: '#',
            attribute: { string_no_quotes: 'variations' },
            comparator: '>=',
            value: { integer: '5' }
          }
        )
      end
    end
  end

  describe '#root' do
    subject(:root) { parser.root }

    it 'is expected to eq #predicate' do
      expect(root).to eq(parser.predicate)
    end
  end
end
