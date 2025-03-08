# frozen_string_literal: true

class ProductVariation < ApplicationRecord
  include ProductVariationSearch

  belongs_to :product

  if Gem::Version.new(Rails.version) >= Gem::Version.new('7.0.0')
    enum :stock_status, { in_stock: 1, low_stock: 2, out_of_stock: 3 }
  else
    enum stock_status: { in_stock: 1, low_stock: 2, out_of_stock: 3 }
  end

  validates :title, presence: true

  validates :currency, presence: true
  validates :amount, presence: true, numericality: true
end
