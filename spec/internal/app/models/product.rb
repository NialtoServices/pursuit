# frozen_string_literal: true

class Product < ActiveRecord::Base
  has_many :variations, class_name: 'ProductVariation', inverse_of: :product

  validates :title, presence: true

  searchable do |o|
    o.relation :variations, :title, :stock_status

    o.attribute :title
    o.attribute :description
    o.attribute :rating, unkeyed: false
    o.attribute :title_length, unkeyed: false do
      Arel::Nodes::NamedFunction.new('LENGTH', [
        arel_table[:title]
      ])
    end
  end
end
