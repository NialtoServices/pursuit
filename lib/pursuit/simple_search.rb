# frozen_string_literal: true

module Pursuit
  # Provides an interface for declaring which attributes should be searched in a simple query, and a method for applying
  # a simple query to an `ActiveRecord::Relation` instance.
  #
  class SimpleSearch
    # @return [Set<Arel::Attributes::Attribute>] The attributes to match against.
    #
    attr_accessor :attributes

    # @return [Arel::Table] The default table to retrieve attributes from.
    #
    attr_accessor :default_table

    # Creates a new simple search instance.
    #
    # @param default_table [Arel::Table] The default table to retrieve attributes from.
    # @param block         [Proc]        The proc to invoke in the search instance (optional).
    #
    def initialize(default_table: nil, &block)
      @attributes = Set.new
      @default_table = default_table

      instance_eval(&block) if block
    end

    # Adds an attribute to match against in queries.
    #
    # @param  attribute [Arel::Attributes::Attribute, Symbol] The underlying attribute to query.
    # @return           [Arel::Attributes::Attribute]         The underlying attribute to query.
    #
    def search_attribute(attribute)
      attribute = default_table[attribute] if attribute.is_a?(Symbol)
      attributes.add(attribute)
    end

    # Parse a simple query into an ARel node.
    #
    # @param  query [String]            The simple query.
    # @return       [Arel::Nodes::Node] The ARel node representing the simple query.
    #
    def parse(query)
      value = ActiveRecord::Base.sanitize_sql_like(query)
      value = "%#{value}%"

      attributes.inject(nil) do |previous_node, attribute|
        node = attribute.matches(value)
        next node unless previous_node

        previous_node.or(node)
      end
    end

    # Applies the simple clauses derived from `query` to `relation`.
    #
    # @param  query    [String]                 The simple query.
    # @param  relation [ActiveRecord::Relation] The base relation to apply the simple clauses to.
    # @return          [ActiveRecord::Relation] The base relation with the simple clauses applied.
    #
    def apply(query, relation)
      node = parse(query)
      node ? relation.where(node) : relation.none
    end
  end
end
