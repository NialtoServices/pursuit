# frozen_string_literal: true

class Product < ActiveRecord::Base
  has_many :variations, class_name: 'ProductVariation', inverse_of: :product

  has_search relationships: { variations: %i[title stock_status] },
             keyed_attributes: %i[title description rating],
             unkeyed_attributes: %i[title description]

  validates :title, presence: true
end
