# frozen_string_literal: true

module Pursuit
  # Parser for a list of terms.
  #
  class TermParser < Parslet::Parser
    # Whitespace

    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { match('\s').repeat(0) }

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
      match('[^\s]').repeat(1).as(:string_no_quotes)
    end

    rule(:string) do
      string_double_quotes | string_single_quotes | string_no_quotes
    end

    # Terms

    rule(:term)      { string.as(:term) }
    rule(:term_pair) { term.as(:left) >> space >> term_node.as(:right) }
    rule(:term_node) { term_pair | term }
    rule(:terms)     { space? >> term_node >> space? }
    root(:terms)
  end
end
