# frozen_string_literal: true

# robots.txt — chặn crawl vùng private và trỏ tới sitemap.xml.
class RobotsController < ApplicationController
  layout false

  def show
    render plain: robots_body, content_type: "text/plain; charset=utf-8"
  end

  private

  def robots_body
    sitemap = "#{request.base_url}#{sitemap_path}"
    <<~TEXT
      User-agent: *
      Disallow: /admin
      Disallow: /users
      Disallow: /search

      Sitemap: #{sitemap}
    TEXT
  end
end
