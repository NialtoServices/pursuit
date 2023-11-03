# frozen_string_literal: true

module Pursuit
  # Provides an interface for declaring which attributes can be used in a predicate query, and a method for applying
  # a predicate query to an `ActiveRecord::Relation` instance.
  #
  # @see Pursuit::PredicateParser
  # @see Pursuit::PredicateTransform
  #
  class PredicateSearch
    # @return [Arel::Table] The default table to retrieve attributes from.
    #
    attr_accessor :default_table

    # @return [Boolean] `true` when aggregate modifiers can be used, `false` otherwise.
    #
    attr_accessor :permit_aggregate_modifiers

    # @return [Hash<Symbol, Arel::Attributes::Attribute>] The attributes permitted for use in queries.
    #
    attr_accessor :permitted_attributes

    # Creates a new predicate search instance.
    #
    # @param default_table              [Arel::Table] The default table to retrieve attributes from.
    # @param permit_aggregate_modifiers [Boolean]     `true` when aggregate modifiers can be used, `false` otherwise.
    # @param block                      [Proc]        The proc to invoke in the search instance (optional).
    #
    def initialize(default_table: nil, permit_aggregate_modifiers: false, &block)
      @default_table = default_table
      @permit_aggregate_modifiers = permit_aggregate_modifiers
      @permitted_attributes = HashWithIndifferentAccess.new

      instance_eval(&block) if block
    end

    # @return [Pursuit::PredicateParser] The parser which converts queries into trees.
    #
    def parser
      @parser ||= PredicateParser.new
    end

    # @return [Pursuit::PredicateTransform] The transform which converts trees into ARel nodes.
    #
    def transform
      @transform ||= PredicateTransform.new
    end

    # Permits use of the specified attribute in predicate queries.
    #
    # @param  name      [Symbol]                              The name used in the query.
    # @param  attribute [Arel::Attributes::Attribute, Symbol] The underlying attribute to query.
    # @return           [Arel::Attributes::Attribute]         The underlying attribute to query.
    #
    def permit_attribute(name, attribute = nil)
      attribute = default_table[attribute] if attribute.is_a?(Symbol)
      permitted_attributes[name] = attribute || default_table[name]
    end

    # Parse a predicate query into ARel nodes.
    #
    # @param  query [String]                          The predicate query.
    # @return       [Hash<Symbol, Arel::Nodes::Node>] The ARel nodes representing the predicate query.
    #
    def parse(query)
      transform.apply(
        parser.parse(query),
        permit_aggregate_modifiers: permit_aggregate_modifiers,
        permitted_attributes: permitted_attributes
      )
    end

    # Applies the predicate clauses derived from `query` to `relation`.
    #
    # @param  query    [String]                 The predicate query.
    # @param  relation [ActiveRecord::Relation] The base relation to apply the predicate clauses to.
    # @return          [ActiveRecord::Relation] The base relation with the predicate clauses applied.
    #
    def apply(query, relation)
      nodes = parse(query)
      relation = relation.where(nodes[:where]) if nodes[:where]
      relation = relation.having(nodes[:having]) if nodes[:having]
      relation
    end
  end
end
