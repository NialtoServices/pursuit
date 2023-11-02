# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :category, class_name: 'ProductCategory', inverse_of: :products, optional: true

  has_many :variations, class_name: 'ProductVariation', inverse_of: :product

  validates :title, presence: true

  def self.predicate_search
    @predicate_search ||= Pursuit::PredicateSearch.new(
      left_outer_joins(:category, :variations).group(:id).order(:title)
    ) do
      permit_attribute :title
      permit_attribute :category, ProductCategory.arel_table[:id]
      permit_attribute :category_name, ProductCategory.arel_table[:name]
      permit_attribute :variation, ProductVariation.arel_table[:id]
      permit_attribute :variation_title, ProductVariation.arel_table[:title]
      permit_attribute :variation_currency, ProductVariation.arel_table[:currency]
      permit_attribute :variation_amount, ProductVariation.arel_table[:amount]
    end
  end

  def self.term_search
    @term_search ||= Pursuit::TermSearch.new(
      left_outer_joins(:category).group(:id).order(:title)
    ) do
      search_attribute :title
      search_attribute ProductCategory.arel_table[:name]
    end
  end

  def self.search(query)
    predicate_search.apply(query)
  rescue Parslet::ParseFailed
    term_search.apply(query)
  end
end
