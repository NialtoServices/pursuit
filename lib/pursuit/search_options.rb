# frozen_string_literal: true

module Pursuit
  class SearchOptions
    # @return [Class<ActiveRecord::Base>] The `ActiveRecord::Base` child class to search.
    #
    attr_reader :record_class

    # @return [Hash<Symbol, Array<Symbol>>] The record's relatives and the attribute names that can be searched.
    #
    attr_reader :relations

    # @return [Hash<Symbol, Proc>] The attribute names which can be searched with a keyed term (e.g. 'last_name:*herb').
    #
    attr_reader :keyed_attributes

    # @return [Hash<Symbol, Proc>] The attribute names which can be searched with an unkeyed term (e.g. 'herb').
    #
    attr_reader :unkeyed_attributes

    # Create a new `SearchOptions` ready for adding options.
    #
    # @params record_class [Class<ActiveRecord::Base>]
    # @params block [Proc]
    #
    def initialize(record_class, &block)
      @record_class = record_class
      @relations = {}
      @keyed_attributes = {}
      @unkeyed_attributes = {}

      block.call(self) if block
    end

    # @return [Array<String>] The collection of all possible attributes which can be used as a keyed term.
    #
    def keys
      keys = relations.keys + keyed_attributes.keys
      keys.map(&:to_s).uniq
    end

    # Add a relation to the search options.
    #
    # @param name            [Symbol] The name of the relationship attribute.
    # @param attribute_names [Splat]  The name of the attributes within the relationship to search.
    #
    def relation(name, *attribute_names)
      relations[name] = attribute_names
      nil
    end

    # Add a keyed attribute to search.
    #
    # @param name  [Symbol] The name of the attribute.
    # @param block [Proc]   A block which returns an arel node to query against instead of a real attribute.
    #
    def keyed(name, &block)
      keyed_attributes[name] = block || -> { record_class.arel_table[name] }
      nil
    end

    # Add an unkeyed attribute to search.
    #
    # @param name  [Symbol] The name of the attribute.
    # @param block [Proc]   A block which returns an arel node to query against instead of a real attribute.
    #
    def unkeyed(name, &block)
      unkeyed_attributes[name] = block || -> { record_class.arel_table[name] }
      nil
    end
  end
end
