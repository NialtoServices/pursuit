# frozen_string_literal: true

class ProductVariation < ApplicationRecord
  belongs_to :product

  enum stock_status: { in_stock: 1, low_stock: 2, out_of_stock: 3 }

  validates :title, presence: true

  validates :currency, presence: true
  validates :amount, presence: true, numericality: true

  def self.predicate_search
    @predicate_search ||= Pursuit::PredicateSearch.new(
      left_outer_joins(:product).group(:id)
    ) do
      permit_attribute :title
      permit_attribute :stock_status
      permit_attribute :currency
      permit_attribute :amount
      permit_attribute :product, Product.arel_table[:id]
      permit_attribute :product_title, Product.arel_table[:title]
    end
  end

  def self.term_search
    @term_search ||= Pursuit::TermSearch.new(all) do
      search_attribute :title
    end
  end

  def self.search(query)
    predicate_search.apply(query)
  rescue Parslet::ParseFailed
    term_search.apply(query)
  end
end
