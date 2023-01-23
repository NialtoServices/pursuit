# frozen_string_literal: true

class Product < ActiveRecord::Base
  belongs_to :category, class_name: 'ProductCategory', inverse_of: :products, optional: true

  has_many :variations, class_name: 'ProductVariation', inverse_of: :product

  validates :title, presence: true
end
