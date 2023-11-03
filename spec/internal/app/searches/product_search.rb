# frozen_string_literal: true

module ProductSearch
  extend ActiveSupport::Concern

  class_methods do
    # Search for records matching the specified predicate.
    #
    # @param  query [String]                 The query with a predicate.
    # @return       [ActiveRecord::Relation] The current relation filtered by the predicate.
    #
    def predicate_search(query)
      @predicate_search ||= Pursuit::PredicateSearch.new(default_table: arel_table) do
        permit_attribute :title
        permit_attribute :category, ProductCategory.arel_table[:id]
        permit_attribute :category_name, ProductCategory.arel_table[:name]
        permit_attribute :variation, ProductVariation.arel_table[:id]
        permit_attribute :variation_title, ProductVariation.arel_table[:title]
        permit_attribute :variation_currency, ProductVariation.arel_table[:currency]
        permit_attribute :variation_amount, ProductVariation.arel_table[:amount]
      end

      @predicate_search.apply(query, left_outer_joins(:category, :variations).group(:id).order(:title))
    end

    # Search for records matching the specified terms.
    #
    # @param  query [String]                 The query with one or more terms.
    # @return       [ActiveRecord::Relation] The current relation filtered by the terms.
    #
    def term_search(query)
      @term_search ||= Pursuit::TermSearch.new(default_table: arel_table) do
        search_attribute :title
        search_attribute ProductCategory.arel_table[:name]
      end

      @term_search.apply(query, left_outer_joins(:category).group(:id).order(:title))
    end

    # Search for records matching the specified query.
    #
    # @param  query [String]                 The query.
    # @return       [ActiveRecord::Relation] The current relation filtered by the query.
    #
    def search(query)
      return none if query.blank?

      predicate_search(query)
    rescue Parslet::ParseFailed
      term_search(query)
    end
  end
end
