# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :products, force: true do |t|
    t.string :title, null: false

    t.text :description

    t.integer :rating, limit: 1

    t.timestamps null: false
  end

  create_table :product_variations, force: true do |t|
    t.belongs_to :product, null: false, foreign_key: true

    t.string :title, null: false

    t.string :currency, null: false, default: 'USD'
    t.integer :amount, null: false, default: 0

    t.integer :stock_status, limit: 1

    t.timestamps null: false
  end
end
