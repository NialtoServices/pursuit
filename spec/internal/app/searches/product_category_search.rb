# frozen_string_literal: true

module ProductCategorySearch
  extend ActiveSupport::Concern

  class_methods do
    # Search for records matching the specified predicate.
    #
    # @param  query [String]                 The query with a predicate.
    # @return       [ActiveRecord::Relation] The current relation filtered by the predicate.
    #
    def predicate_search(query)
      @predicate_search ||= Pursuit::PredicateSearch.new(default_table: arel_table) do
        permit_attribute :name
        permit_attribute :product, Product.arel_table[:id]
        permit_attribute :product_title, Product.arel_table[:title]
      end

      @predicate_search.apply(query, left_outer_joins(:products).group(:id))
    end

    # Search for records matching the specified terms.
    #
    # @param  query [String]                 The query with one or more terms.
    # @return       [ActiveRecord::Relation] The current relation filtered by the terms.
    #
    def term_search(query)
      @term_search ||= Pursuit::TermSearch.new(default_table: arel_table) do
        search_attribute :name
      end

      # Note that we're using `all` here, but this still works when used in a chain:
      # => ProductVariation.where(stock_status: :in_stock).search('Green')
      @term_search.apply(query, all)
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
