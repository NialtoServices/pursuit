# frozen_string_literal: true

module Pursuit
  class Search
    # @return [SearchOptions] The options to use when building the search query.
    #
    attr_reader :options

    # Create a new instance to search a specific ActiveRecord record class.
    #
    # @param options [SearchOptions]
    #
    def initialize(options)
      @options = options
    end

    # Perform a search for the specified query.
    #
    # @param  query [String]                 The query to transform into a SQL search.
    # @return       [ActiveRecord::Relation] The search results.
    #
    def perform(query)
      options.record_class.where(build_arel(query))
    end

    private

    def build_arel(query)
      parser = SearchTermParser.new(query, keys: options.keys)
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

      sanitized_value = "%#{ActiveRecord::Base.sanitize_sql_like(value)}%"
      options.unkeyed_attributes.reduce(nil) do |chain, (attribute_name, node_builder)|
        node = node_builder.call.matches(sanitized_value)
        chain ? chain.or(node) : node
      end
    end

    def build_arel_for_keyed_terms(terms)
      return nil if terms.blank?

      terms.reduce(nil) do |chain, term|
        attribute_name = term.key.to_sym
        reflection = options.relations.key?(attribute_name) ? options.record_class.reflections[term.key] : nil
        node = if reflection.present?
                 attribute_names = options.relations[attribute_name]
                 build_arel_for_reflection(reflection, attribute_names, term.operator, term.value)
               else
                 node_builder = options.keyed_attributes[attribute_name]
                 build_arel_for_node(node_builder.call, term.operator, term.value)
               end

        chain ? chain.and(node) : node
      end
    end

    def build_arel_for_node(node, operator, value)
      sanitized_value = ActiveRecord::Base.sanitize_sql_like(value)
      sanitized_value = sanitized_value.to_i if sanitized_value =~ /^[0-9]+$/

      case operator
      when '>'   then node.gt(sanitized_value)
      when '>='  then node.gteq(sanitized_value)
      when '<'   then node.lt(sanitized_value)
      when '<='  then node.lteq(sanitized_value)
      when '*='  then node.matches("%#{sanitized_value}%")
      when '!*=' then node.does_not_match("%#{sanitized_value}%")
      when '!='  then node.not_eq(sanitized_value)
      when '=='
        if value.present?
          node.eq(sanitized_value)
        else
          node.eq(nil).or(node.eq(''))
        end
      else
        raise "The operator '#{operator}' is not supported."
      end
    end

    def build_arel_for_reflection(reflection, attribute_names, operator, value)
      nodes = build_arel_for_reflection_join(reflection)
      count_nodes = build_arel_for_relation_count(nodes, operator, value)
      return count_nodes if count_nodes.present?

      match_nodes = attribute_names.reduce(nil) do |chain, attribute_name|
        node = build_arel_for_node(reflection.klass.arel_table[attribute_name], operator, value)
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
          reflection_through_table[reflection_through.foreign_key].eq(
            options.record_class.arel_table[options.record_class.primary_key]
          )
        )
      else
        # :has_one / :has_many
        reflection_table.where(
          reflection_table[reflection.foreign_key].eq(
            options.record_class.arel_table[options.record_class.primary_key]
          )
        )
      end
    end

    def build_arel_for_relation_count(nodes, operator, value)
      node_builder = proc do |klass|
        count = ActiveRecord::Base.sanitize_sql_like(value).to_i
        klass.new(nodes.project(Arel.star.count), count)
      end

      case operator
      when '>'  then node_builder.call(Arel::Nodes::GreaterThan)
      when '>=' then node_builder.call(Arel::Nodes::GreaterThanOrEqual)
      when '<'  then node_builder.call(Arel::Nodes::LessThan)
      when '<=' then node_builder.call(Arel::Nodes::LessThanOrEqual)
      else
        return nil unless value =~ /^([0-9]+)$/

        case operator
        when '=='  then node_builder.call(Arel::Nodes::Equality)
        when '!='  then node_builder.call(Arel::Nodes::NotEqual)
        when '*='  then node_builder.call(Arel::Nodes::Matches)
        when '!*=' then node_builder.call(Arel::Nodes::DoesNotMatch)
        end
      end
    end
  end
end
