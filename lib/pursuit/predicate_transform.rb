# frozen_string_literal: true

module Pursuit
  # Transform for the tree produced by `Pursuit::PredicateParser`.
  #
  # @see Pursuit::PredicateParser
  #
  class PredicateTransform < Parslet::Transform
    # @return [Hash<String, Symbol>] The list of supported aggregate modifiers, and the method name to invoke on the
    #                                attribute node in order to obtain the function node.
    #
    AGGREGATE_MODIFIERS = {
      '#' => :count,
      '*' => :sum,
      '+' => :maximum,
      '-' => :minimum,
      '~' => :average
    }.freeze

    # Boolean Types

    rule(truthy: simple(:_)) { true }
    rule(falsey: simple(:_)) { false }

    # Numeric Types

    rule(integer: simple(:value)) { Integer(value) }
    rule(decimal: simple(:value)) { BigDecimal(value) }

    # String Types

    rule(string_double_quotes: [])             { '' }
    rule(string_double_quotes: simple(:value)) { value.to_s.gsub(/\\(.)/, '\1') }

    rule(string_single_quotes: [])             { '' }
    rule(string_single_quotes: simple(:value)) { value.to_s.gsub(/\\(.)/, '\1') }

    rule(string_no_quotes: simple(:value)) { value.to_s }

    # Comparisons

    rule(attribute: simple(:attribute), comparator: '=', value: simple(:value)) do |context|
      eq_node(attribute(context), context[:value])
    end

    rule(attribute: simple(:attribute), comparator: '!=', value: simple(:value)) do |context|
      not_eq_node(attribute(context), context[:value])
    end

    rule(attribute: simple(:attribute), comparator: '<', value: simple(:value)) do |context|
      lt_node(attribute(context), context[:value])
    end

    rule(attribute: simple(:attribute), comparator: '>', value: simple(:value)) do |context|
      gt_node(attribute(context), context[:value])
    end

    rule(attribute: simple(:attribute), comparator: '<=', value: simple(:value)) do |context|
      lteq_node(attribute(context), context[:value])
    end

    rule(attribute: simple(:attribute), comparator: '>=', value: simple(:value)) do |context|
      gteq_node(attribute(context), context[:value])
    end

    rule(attribute: simple(:attribute), comparator: '~', value: simple(:value)) do |context|
      match_node(attribute(context), context[:value])
    end

    rule(attribute: simple(:attribute), comparator: '!~', value: simple(:value)) do |context|
      does_not_match_node(attribute(context), context[:value])
    end

    # Aggregate Comparisons

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '=',
      value: simple(:value)
    ) do |context|
      eq_node(aggregate_attribute(context), context[:value])
    end

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '!=',
      value: simple(:value)
    ) do |context|
      not_eq_node(aggregate_attribute(context), context[:value])
    end

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '<',
      value: simple(:value)
    ) do |context|
      lt_node(aggregate_attribute(context), context[:value])
    end

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '>',
      value: simple(:value)
    ) do |context|
      gt_node(aggregate_attribute(context), context[:value])
    end

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '<=',
      value: simple(:value)
    ) do |context|
      lteq_node(aggregate_attribute(context), context[:value])
    end

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '>=',
      value: simple(:value)
    ) do |context|
      gteq_node(aggregate_attribute(context), context[:value])
    end

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '~',
      value: simple(:value)
    ) do |context|
      match_node(aggregate_attribute(context), context[:value])
    end

    rule(
      aggregate_modifier: simple(:aggregate_modifier),
      attribute: simple(:attribute),
      comparator: '!~',
      value: simple(:value)
    ) do |context|
      does_not_match_node(aggregate_attribute(context), context[:value])
    end

    # Joins

    rule(left: simple(:left), joiner: '&', right: simple(:right)) do
      left.and(right)
    end

    rule(left: simple(:left), joiner: '|', right: simple(:right)) do
      left.or(right)
    end

    # Helpers

    class << self
      def attribute(context)
        attribute_name = context[:attribute].to_sym
        attribute = context.dig(:permitted_attributes, attribute_name)
        raise AttributeNotFound, attribute_name if attribute.blank?
        raise AggregateModifierRequired, attribute_name if attribute.respond_to?(:name) && attribute.name == Arel.star

        attribute
      end

      def aggregate_attribute(context)
        raise AggregateModifiersNotAvailable unless context[:permit_aggregate_modifiers]

        attribute_name = context[:attribute].to_sym
        attribute = context.dig(:permitted_attributes, attribute_name)
        raise AttributeNotFound, attribute_name if attribute.blank?

        aggregate_modifier_name = context[:aggregate_modifier].to_s
        aggregate_modifier = AGGREGATE_MODIFIERS[aggregate_modifier_name]
        raise AggregateModifierNotFound, aggregate_modifier_name unless aggregate_modifier

        attribute.public_send(aggregate_modifier)
      end

      def eq_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql(value) if value.is_a?(String)
        return attribute.eq(value) if value.present?

        attribute.eq(nil).or(attribute.matches_regexp('^\s*$'))
      end

      def not_eq_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql(value) if value.is_a?(String)
        return attribute.not_eq(value) if value.present?

        attribute.not_eq(nil).and(attribute.does_not_match_regexp('^\s*$'))
      end

      def gt_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql(value) if value.is_a?(String)
        attribute.gt(value)
      end

      def gteq_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql(value) if value.is_a?(String)
        attribute.gteq(value)
      end

      def lt_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql(value) if value.is_a?(String)
        attribute.lt(value)
      end

      def lteq_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql(value) if value.is_a?(String)
        attribute.lteq(value)
      end

      def match_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql_like(value) if value.is_a?(String)
        value = value.blank? ? '%' : "%#{value}%"
        attribute.matches(value)
      end

      def does_not_match_node(attribute, value)
        value = ActiveRecord::Base.sanitize_sql_like(value) if value.is_a?(String)
        value = value.blank? ? '%' : "%#{value}%"
        attribute.does_not_match(value)
      end
    end
  end
end
