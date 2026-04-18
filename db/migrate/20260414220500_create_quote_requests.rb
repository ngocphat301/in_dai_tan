# frozen_string_literal: true

class CreateQuoteRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_requests do |t|
      t.string :customer_name, null: false
      t.string :phone, null: false
      t.references :product, null: false, foreign_key: true
      t.references :product_category, null: false, foreign_key: true
      t.text :body
      t.boolean :staff_received, default: false, null: false
      t.string :purchase_status, default: "pending", null: false

      t.timestamps
    end

    add_index :quote_requests, :staff_received
    add_index :quote_requests, :purchase_status
    add_index :quote_requests, :created_at
  end
end
