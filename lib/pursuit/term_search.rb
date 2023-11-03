# frozen_string_literal: true

module Pursuit
  # Provides an interface for declaring which attributes should be searched in a term query, and a method for applying
  # a term query to an `ActiveRecord::Relation` instance.
  #
  # @see Pursuit::TermParser
  # @see Pursuit::TermTransform
  #
  class TermSearch
    # @return [Set<Arel::Attributes::Attribute>] The attributes to match against.
    #
    attr_accessor :attributes

    # @return [Arel::Table] The default table to retrieve attributes from.
    #
    attr_accessor :default_table

    # Creates a new term search instance.
    #
    # @param default_table [Arel::Table] The default table to retrieve attributes from.
    # @param block         [Proc]        The proc to invoke in the search instance (optional).
    #
    def initialize(default_table: nil, &block)
      @attributes = Set.new
      @default_table = default_table

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
      attribute = default_table[attribute] if attribute.is_a?(Symbol)
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

    # Applies the term clauses derived from `query` to `relation`.
    #
    # @param  query    [String]                 The term query.
    # @param  relation [ActiveRecord::Relation] The base relation to apply the term clauses to.
    # @return          [ActiveRecord::Relation] The base relation with the term clauses applied.
    #
    def apply(query, relation)
      node = parse(query)
      node ? relation.where(node) : relation.none
    end
  end
end
