# frozen_string_literal: true

module Pursuit
  # Transform for a list of terms.
  #
  class TermTransform < Parslet::Transform
    # String Types

    rule(string_double_quotes: [])             { '' }
    rule(string_double_quotes: simple(:value)) { value.to_s.gsub(/\\(.)/, '\1') }

    rule(string_single_quotes: [])             { '' }
    rule(string_single_quotes: simple(:value)) { value.to_s.gsub(/\\(.)/, '\1') }

    rule(string_no_quotes: simple(:value)) { value.to_s }

    # Terms

    rule(term: simple(:term)) do |context|
      value = ActiveRecord::Base.sanitize_sql_like(context[:term])
      value = "%#{value}%"

      context[:attributes].inject(nil) do |previous_node, attribute|
        node = attribute.matches(value)
        next node unless previous_node

        previous_node.or(node)
      end
    end

    # Joins

    rule(left: simple(:left), right: simple(:right)) { left.and(right) }
  end
end
