# frozen_string_literal: true

module Pursuit
  class SearchOptions
    # @return [Struct] The structure which holds the search options for a single attribute.
    #
    AttributeOptions = Struct.new(:keyed, :unkeyed, :block)

    # @return [Class<ActiveRecord::Base>] The `ActiveRecord::Base` child class to search.
    #
    attr_reader :record_class

    # @return [Hash<Symbol, Array<Symbol>>] The attribute names of the record's relatives which can be searched.
    #
    attr_reader :relations

    # @return [Hash<Symbol, AttributeOptions>] The attributes which can be searched.
    #
    attr_reader :attributes

    # Create a new `SearchOptions` and call the passed block to setup the options.
    #
    # @params record_class [Class<ActiveRecord::Base>]
    # @params block        [Proc]
    #
    def initialize(record_class, &block)
      @record_class = record_class
      @relations = {}
      @attributes = {}

      block.call(self) if block
    end

    # @return [Hash<Symbol, Proc>] The attributes which can be queried using a keyed term.
    #
    def keyed_attributes
      attributes.each_with_object({}) do |(name, options), keyed_attributes|
        keyed_attributes[name] = options.block if options.keyed
      end
    end

    # @return [Hash<Symbol, Proc>] The attributes which can be queried using an unkeyed term.
    #
    def unkeyed_attributes
      attributes.each_with_object({}) do |(name, options), unkeyed_attributes|
        unkeyed_attributes[name] = options.block if options.unkeyed
      end
    end

    # @return [Array<String>] The collection of all possible attributes which can be used as a keyed term.
    #
    def keys
      keys = relations.keys + attributes.select { |_, a| a.keyed }.keys
      keys.map(&:to_s).uniq
    end

    # Add a relation to search.
    #
    # @param name            [Symbol] The name of the relationship attribute.
    # @param attribute_names [Splat]  The name of the attributes within the relationship to search.
    #
    def relation(name, *attribute_names)
      relations[name] = attribute_names
      nil
    end

    # Add an attribute to search.
    #
    # @param term_name      [Symbol]  The keyed search term (can be an existing attribute, or a custom value when
    #                                 passing either the `attribute_name` or a block returning an Arel node).
    # @param attribute_name [Symbol]  The attribute name to search (defaults to the keyword, when left blank and no
    #                                 block is passed).
    # @param keyed          [Boolean] `true` when the attribute should be searchable using a keyed term,
    #                                 `false` otherwise.
    # @param unkeyed        [Boolean] `true` when the attribute should be searchable using an unkeyed term,
    #                                 `false` otherwise.
    # @param block          [Proc]    A block which returns the Arel node to query against. When left blank, the
    #                                 matching attribute from `.arel_table` is queried instead.
    #
    def attribute(term_name, attribute_name = nil, keyed: true, unkeyed: true, &block)
      block ||= -> { record_class.arel_table[attribute_name || term_name] }
      attributes[term_name] = AttributeOptions.new(keyed, unkeyed, block)
      nil
    end
  end
end
