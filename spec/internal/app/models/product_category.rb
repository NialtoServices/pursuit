# frozen_string_literal: true

class ProductCategory < ApplicationRecord
  has_many :products, class_name: 'Product', foreign_key: :category_id, inverse_of: :category, dependent: :nullify

  validates :name, presence: true

  def self.predicate_search
    @predicate_search ||= Pursuit::PredicateSearch.new(
      left_outer_joins(:products).group(:id)
    ) do
      permit_attribute :name
      permit_attribute :product, Product.arel_table[:id]
      permit_attribute :product_title, Product.arel_table[:title]
    end
  end

  def self.term_search
    @term_search ||= Pursuit::TermSearch.new(all) do
      search_attribute :name
    end
  end

  def self.search(query)
    predicate_search.apply(query)
  rescue Parslet::ParseFailed
    term_search.apply(query)
  end
end
