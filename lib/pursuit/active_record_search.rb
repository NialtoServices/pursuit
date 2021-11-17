# frozen_string_literal: true

module Pursuit
  class ActiveRecordSearch
    # @return [Class<ActiveRecord::Base>] The `ActiveRecord::Base` child class being searched.
    #
    attr_reader :klass

    # @return [Hash<Symbol, Array<Symbol>>] The attribute names for relationships which can be queried with a keyed
    #                                       term and the attributes in the relative's table which should be searched.
    #
    attr_accessor :relationships

    # @return [Array<Symbol>] The attribute names which can be queried with a keyed term (e.g. 'last_name:*herb').
    #
    attr_accessor :keyed_attributes

    # @return [Array<Symbol>] The attribute names which can be queried with an unkeyed term (e.g. 'herb').
    #
    attr_accessor :unkeyed_attributes

    # Create a new instance to search a specific ActiveRecord record class.
    #
    # @param klass              [Class<ActiveRecord::Base>]
    # @param relationships      [Hash<Symbol, Array<Symbol>>]
    # @param keyed_attributes   [Array<Symbol>]
    # @param unkeyed_attributes [Array<Symbol>]
    #
    def initialize(klass, relationships: {}, keyed_attributes: [], unkeyed_attributes: [])
      @klass = klass
      @relationships = relationships
      @keyed_attributes = keyed_attributes
      @unkeyed_attributes = unkeyed_attributes
    end

    # Search the record with the specified query.
    #
    # @param  query [String]                 The query to transform into a SQL search.
    # @return       [ActiveRecord::Relation] The search results.
    #
    def search(query)
      klass.where(build_arel(query))
    end

    private

    def build_arel(query)
      parser = TermParser.new(query, keys: relationships.keys + keyed_attributes)
      unkeyed_arel = build_arel_for_unkeyed_term(parser.unkeyed_term)
      keyed_arel = build_arel_for_keyed_terms(parser.keyed_terms)

      if unkeyed_arel && keyed_arel
        unkeyed_arel.and(keyed_arel)
      else
        unkeyed_arel || keyed_arel
      end
    end

    def build_arel_for_unkeyed_term(value)
      return nil if value.blank?

      sanitized_value = "%#{klass.sanitize_sql_like(value)}%"
      unkeyed_attributes.reduce(nil) do |chain, attribute_name|
        node = klass.arel_table[attribute_name].matches(sanitized_value)
        chain ? chain.or(node) : node
      end
    end

    def build_arel_for_keyed_terms(terms)
      return nil if terms.blank?

      terms.reduce(nil) do |chain, term|
        reflection = klass.reflections[term.key]
        node = if reflection.present?
                 keys = relationships[term.key.to_sym].presence || []
                 build_arel_for_reflection(reflection, keys, term.operator, term.value)
               else
                 build_arel_for_attribute(klass.arel_table[term.key], term.operator, term.value)
               end

        chain ? chain.and(node) : node
      end
    end

    def build_arel_for_attribute(attribute, operator, value)
      sanitized_value = ActiveRecord::Base.sanitize_sql_like(value)

      case operator
      when '>'   then attribute.gt(sanitized_value)
      when '>='  then attribute.gteq(sanitized_value)
      when '<'   then attribute.lt(sanitized_value)
      when '<='  then attribute.lteq(sanitized_value)
      when '*='  then attribute.matches("%#{sanitized_value}%")
      when '!*=' then attribute.does_not_match("%#{sanitized_value}%")
      when '!='  then attribute.not_eq(sanitized_value)
      when '=='
        if value.present?
          attribute.eq(sanitized_value)
        else
          attribute.eq(nil).or(attribute.eq(''))
        end
      else
        raise "The operator '#{operator}' is not supported."
      end
    end

    def build_arel_for_reflection(reflection, relation_attributes, operator, value)
      nodes = build_arel_for_reflection_join(reflection)
      count_nodes = build_arel_for_relation_count(nodes, operator, value)
      return count_nodes if count_nodes.present?

      match_nodes = relation_attributes.reduce(nil) do |chain, attribute_name|
        node = build_arel_for_attribute(reflection.klass.arel_table[attribute_name], operator, value)
        chain ? chain.or(node) : node
      end

      return nil if match_nodes.blank?

      nodes.where(match_nodes).project(1).exists
    end

    def build_arel_for_reflection_join(reflection)
      reflection_table = reflection.klass.arel_table
      reflection_through = reflection.through_reflection

      if reflection_through.present?
        # :has_one through / :has_many through
        reflection_through_table = reflection_through.klass.arel_table
        reflection_table.join(reflection_through_table).on(
          reflection_through_table[reflection.foreign_key].eq(reflection_table[reflection.klass.primary_key])
        ).where(
          reflection_through_table[reflection_through.foreign_key].eq(klass.arel_table[klass.primary_key])
        )
      else
        # :has_one / :has_many
        reflection_table.where(
          reflection_table[reflection.foreign_key].eq(klass.arel_table[klass.primary_key])
        )
      end
    end

    def build_arel_for_relation_count(nodes, operator, value)
      build = proc do |klass|
        count = ActiveRecord::Base.sanitize_sql_like(value).to_i
        klass.new(nodes.project(Arel.star.count), count)
      end

      case operator
      when '>'  then build.call(Arel::Nodes::GreaterThan)
      when '>=' then build.call(Arel::Nodes::GreaterThanOrEqual)
      when '<'  then build.call(Arel::Nodes::LessThan)
      when '<=' then build.call(Arel::Nodes::LessThanOrEqual)
      else
        return nil unless value =~ /^([0-9]+)$/

        case operator
        when '=='  then build.call(Arel::Nodes::Equality)
        when '!='  then build.call(Arel::Nodes::NotEqual)
        when '*='  then build.call(Arel::Nodes::Matches)
        when '!*=' then build.call(Arel::Nodes::DoesNotMatch)
        end
      end
    end
  end
end
