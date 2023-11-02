# frozen_string_literal: true

module Pursuit
  # :nodoc:
  #
  class PredicateSearch
    # @return [Boolean] `true` when aggregate modifiers can be used in queries, `false` otherwise.
    #
    attr_accessor :permit_aggregate_modifiers

    # @return [Hash<Symbol, Arel::Attributes::Attribute>] The attributes permitted for use in queries.
    #
    attr_reader :permitted_attributes

    # @return [ActiveRecord::Relation] The relation to which the predicate clauses are added.
    #
    attr_reader :relation

    # Creates a new predicate search instance.
    #
    # @param relation                   [ActiveRecord::Relation] The relation to which the predicate clauses are added.
    # @param permit_aggregate_modifiers [Boolean]                Whether aggregate modifiers can be used or not.
    # @param block                      [Proc]                   The proc to invoke in the search instance (optional).
    #
    def initialize(relation, permit_aggregate_modifiers: false, &block)
      @relation = relation
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
      attribute = relation.klass.arel_table[attribute] if attribute.is_a?(Symbol)
      permitted_attributes[name] = attribute || relation.klass.arel_table[name]
    end

    # Parse a predicate query into ARel nodes.
    #
    # @param  query [String]                          The predicate query.
    # @return       [Hash<Symbol, Arel::Nodes::Node>] The ARel nodes representing the predicate query.
    #
    def parse(query)
      tree = parser.parse(query)
      transform.apply(
        tree,
        permitted_attributes: permitted_attributes,
        permit_aggregate_modifiers: permit_aggregate_modifiers
      )
    end

    # Returns #relation filtered by the predicate query.
    #
    # @param  query [String]                 The predicate query.
    # @return       [ActiveRecord::Relation] The updated relation with the predicate clauses added.
    #
    def apply(query)
      nodes = parse(query)
      relation = self.relation
      relation = relation.where(nodes[:where]) if nodes[:where]
      relation = relation.having(nodes[:having]) if nodes[:having]
      relation
    end
  end
end
