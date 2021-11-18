# frozen_string_literal: true

class Product < ActiveRecord::Base
  has_many :variations, class_name: 'ProductVariation', inverse_of: :product

  validates :title, presence: true

  searchable do |o|
    o.relation :variations, :title, :stock_status

    o.keyed :title
    o.keyed :description
    o.keyed :rating

    o.keyed :title_length do
      Arel::Nodes::NamedFunction.new('LENGTH', [
        arel_table[:title]
      ])
    end

    o.unkeyed :title
    o.unkeyed :description
  end
end
