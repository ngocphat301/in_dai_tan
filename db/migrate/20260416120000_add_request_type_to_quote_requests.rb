# frozen_string_literal: true

class AddRequestTypeToQuoteRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :quote_requests, :request_type, :string, null: false, default: "product"
    add_index :quote_requests, :request_type

    change_column_null :quote_requests, :product_id, true
    change_column_null :quote_requests, :product_category_id, true
  end
end
