# frozen_string_literal: true

module Pursuit
  # Parser for predicate queries.
  #
  # Predicate queries take an attribute, an operator (such as the equal sign), and a value to compare with.
  #
  # For example, to search for records where the `first_name` attribute is equal to "John" and the `last_name`
  # attribute contains either "Doe" or "Smith", you might use:
  #
  # => "first_name = John & (last_name ~ Doe | last_name ~ Smith)"
  #
  class PredicateParser < Parslet::Parser
    # Whitespace

    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { match('\s').repeat(0) }

    # Boolean Types

    rule(:boolean_true)  { stri('true').as(:truthy) }
    rule(:boolean_false) { stri('false').as(:falsey) }
    rule(:boolean)       { boolean_true | boolean_false }

    # Numeric Types

    rule(:numeric_prefix) do
      str('+') | str('-')
    end

    rule(:integer) do
      (numeric_prefix.maybe >> match('[0-9]').repeat(1)).as(:integer)
    end

    rule(:decimal) do
      (numeric_prefix.maybe >> match('[0-9]').repeat(0) >> str('.') >> match('[0-9]').repeat(1)).as(:decimal)
    end

    rule(:number) do
      decimal | integer
    end

    # Character Types

    rule(:escaped_character) do
      str('\\') >> match('.')
    end

    # String Types

    rule(:string_double_quotes) do
      str('"') >> (escaped_character | match('[^"]')).repeat(0).as(:string_double_quotes) >> str('"')
    end

    rule(:string_single_quotes) do
      str("'") >> (escaped_character | match("[^']")).repeat(0).as(:string_single_quotes) >> str("'")
    end

    rule(:string_no_quotes) do
      match("[\\w\\!\\'\\+\\,\\-\\.\\/\\:\\?\\@]").repeat(1).as(:string_no_quotes)
    end

    rule(:string) do
      string_double_quotes | string_single_quotes | string_no_quotes
    end

    # Operators

    rule(:operator_equal)                    { str('=') }
    rule(:operator_not_equal)                { str('!=') }
    rule(:operator_contains)                 { str('~') }
    rule(:operator_not_contains)             { str('!~') }
    rule(:operator_less_than)                { str('<') }
    rule(:operator_greater_than)             { str('>') }
    rule(:operator_less_than_or_equal_to)    { str('<=') }
    rule(:operator_greater_than_or_equal_to) { str('>=') }
    rule(:operator_and)                      { str('&') }
    rule(:operator_or)                       { str('|') }

    rule(:comparator) do
      (
        operator_greater_than_or_equal_to |
        operator_less_than_or_equal_to |
        operator_greater_than |
        operator_less_than |
        operator_not_contains |
        operator_contains |
        operator_not_equal |
        operator_equal
      ).as(:comparator)
    end

    rule(:joiner) do
      (
        operator_and |
        operator_or
      ).as(:joiner)
    end

    # Comparison Operands

    rule(:aggregate_modifier) do
      match('[\#\*\+\-\~]').as(:aggregate_modifier)
    end

    rule(:attribute) do
      string.as(:attribute)
    end

    rule(:value) do
      (boolean | number | string).as(:value)
    end

    # Comparison

    rule(:comparison) do
      attribute >> space? >> comparator >> space? >> value
    end

    rule(:comparison_group) do
      str('(') >> space? >> comparison_node >> space? >> str(')')
    end

    rule(:comparison_join) do
      (comparison_group | comparison).as(:left) >> space? >> joiner >> space? >> comparison_node.as(:right)
    end

    rule(:comparison_node) do
      comparison_join | comparison_group | comparison
    end

    # Aggregate Comparison

    rule(:aggregate_comparison) do
      aggregate_modifier >> attribute >> space? >> comparator >> space? >> value
    end

    rule(:aggregate_comparison_group) do
      str('(') >> space? >> aggregate_comparison_node >> space? >> str(')')
    end

    rule(:aggregate_comparison_join) do
      (aggregate_comparison_group | aggregate_comparison).as(:left) >>
        space? >> joiner >> space? >> aggregate_comparison_node.as(:right)
    end

    rule(:aggregate_comparison_node) do
      aggregate_comparison_join | aggregate_comparison_group | aggregate_comparison
    end

    # Predicate

    rule(:predicate_where) do
      comparison_node.as(:where)
    end

    rule(:predicate_having) do
      aggregate_comparison_node.as(:having)
    end

    rule(:predicate) do
      space? >> (
        (predicate_where >> space? >> operator_and >> space? >> predicate_having) |
        (predicate_having >> space? >> operator_and >> space? >> predicate_where) |
        predicate_where |
        predicate_having
      ) >> space?
    end

    root(:predicate)

    # Helpers

    def stri(string)
      string
        .each_char
        .map { |c| match("[#{c.upcase}#{c.downcase}]") }
        .reduce(:>>)
    end
  end
end
