# frozen_string_literal: true

class AddAssignedToToQuoteRequests < ActiveRecord::Migration[8.1]
  def change
    add_reference :quote_requests, :assigned_to, foreign_key: { to_table: :users }, null: true
  end
end
