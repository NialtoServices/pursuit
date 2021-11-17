# frozen_string_literal: true

module Pursuit
  class TermParser
    # @return [Struct] Represents a single keyed term extracted from a query.
    #
    KeyedTerm = Struct.new(:key, :operator, :value)

    # @return [Array<Pursuit::TermParser::KeyedTerm>] The keys which are permitted for use as keyed terms.
    #
    attr_reader :keyed_terms

    # @return [String] The unkeyed term.
    #
    attr_reader :unkeyed_term

    # Create a new `TermParser` by parsing the specified query into an 'unkeyed term' and 'keyed terms'.
    #
    # @param query [String]        The query to parse.
    # @param keys  [Array<Symbol>] The keys which are permitted for use as keyed terms.
    #
    def initialize(query, keys: [])
      keys = keys.map(&:to_s)

      @keyed_terms = []
      @unkeyed_term = query.gsub(/(\s+)?(\w+)(==|\*=|!=|!\*=|<=|>=|<|>)("([^"]+)?"|'([^']+)?'|[^\s]+)(\s+)?/) do |term|
        key = Regexp.last_match(2)
        next term unless keys.include?(key)

        operator = Regexp.last_match(3)
        value = Regexp.last_match(4)
        value = value[1..-2] if value =~ /^(".*"|'.*')$/

        @keyed_terms << KeyedTerm.new(key, operator, value)

        # Both the starting and ending spaces surrounding the keyed term can be removed, so in this case we'll need to
        # replace with a single space to ensure the unkeyed term's words are separated correctly.
        if term =~ /^\s.*\s$/
          ' '
        else
          ''
        end
      end

      @unkeyed_term = @unkeyed_term.strip
    end
  end
end
