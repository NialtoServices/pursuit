# frozen_string_literal: true

class ProductVariation < ApplicationRecord
  belongs_to :product

  enum stock_status: { in_stock: 1, low_stock: 2, out_of_stock: 3 }

  validates :title, presence: true

  validates :currency, presence: true
  validates :amount, presence: true, numericality: true
end
