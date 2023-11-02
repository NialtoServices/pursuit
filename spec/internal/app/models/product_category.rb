# frozen_string_literal: true

class ProductCategory < ApplicationRecord
  has_many :products, class_name: 'Product', foreign_key: :category_id, inverse_of: :category, dependent: :nullify

  validates :name, presence: true
end
