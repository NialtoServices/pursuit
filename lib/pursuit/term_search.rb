# frozen_string_literal: true

module Pursuit
  # :nodoc:
  #
  class TermSearch
    # @return [Set<Arel::Attributes::Attribute>] The attributes to match against.
    #
    attr_reader :attributes

    # @return [ActiveRecord::Relation] The relation to which the term clauses are added.
    #
    attr_reader :relation

    # Creates a new term search instance.
    #
    # @param relation [ActiveRecord::Relation] The relation to which the term clauses are added.
    # @param block    [Proc]                   The proc to invoke in the search instance (optional).
    #
    def initialize(relation, &block)
      @attributes = Set.new
      @relation = relation

      instance_eval(&block) if block
    end

    # @return [Pursuit::TermParser] The parser which converts queries into trees.
    #
    def parser
      @parser ||= TermParser.new
    end

    # @return [Pursuit::TermTransform] The transform which converts trees into ARel nodes.
    #
    def transform
      @transform ||= TermTransform.new
    end

    # Adds an attribute to match against in term queries.
    #
    # @param  attribute [Arel::Attributes::Attribute, Symbol] The underlying attribute to query.
    # @return           [Arel::Attributes::Attribute]         The underlying attribute to query.
    #
    def search_attribute(attribute)
      attribute = relation.klass.arel_table[attribute] if attribute.is_a?(Symbol)
      attributes.add(attribute)
    end

    # Parse a term query into an ARel node.
    #
    # @param  query [String]            The term query.
    # @return       [Arel::Nodes::Node] The ARel node representing the term query.
    #
    def parse(query)
      tree = parser.parse(query)
      transform.apply(tree, attributes: attributes)
    end

    # Returns #relation filtered by the term query.
    #
    # @param  query [String]                 The term query.
    # @return       [ActiveRecord::Relation] The updated relation with the term clauses added.
    #
    def apply(query)
      node = parse(query)
      node ? relation.where(node) : relation.none
    end
  end
end
