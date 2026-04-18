# frozen_string_literal: true

class AddBlogPostToQuoteRequests < ActiveRecord::Migration[8.1]
  def change
    add_reference :quote_requests, :blog_post, foreign_key: true
  end
end
