# frozen_string_literal: true

class Product < ApplicationRecord
  include ProductSearch

  belongs_to :category, class_name: 'ProductCategory', inverse_of: :products, optional: true

  has_many :variations, class_name: 'ProductVariation', inverse_of: :product

  validates :title, presence: true
end
