# frozen_string_literal: true

module Pursuit
  # :nodoc:
  #
  class SimpleSearch
    # @return [Set<Arel::Attributes::Attribute>] The attributes to match against.
    #
    attr_reader :attributes

    # @return [ActiveRecord::Relation] The relation to which the clauses are added.
    #
    attr_reader :relation

    # Creates a new simple search instance.
    #
    # @param relation [ActiveRecord::Relation] The relation to which the clauses are added.
    # @param block    [Proc]                   The proc to invoke in the search instance (optional).
    #
    def initialize(relation, &block)
      @attributes = Set.new
      @relation = relation

      instance_eval(&block) if block
    end

    # Adds an attribute to match against in queries.
    #
    # @param  attribute [Arel::Attributes::Attribute, Symbol] The underlying attribute to query.
    # @return           [Arel::Attributes::Attribute]         The underlying attribute to query.
    #
    def search_attribute(attribute)
      attribute = relation.klass.arel_table[attribute] if attribute.is_a?(Symbol)
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

    # Returns #relation filtered by the query.
    #
    # @param  query [String]                 The simple query.
    # @return       [ActiveRecord::Relation] The updated relation with the clauses added.
    #
    def apply(query)
      node = parse(query)
      node ? relation.where(node) : relation.none
    end
  end
end
