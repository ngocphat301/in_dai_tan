# frozen_string_literal: true

xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @urls.each do |u|
    xml.url do
      xml.loc u[:loc]
      if u[:lastmod].present?
        xml.lastmod u[:lastmod].utc.iso8601
      end
      xml.changefreq u[:changefreq] if u[:changefreq].present?
      xml.priority u[:priority] if u[:priority].present?
    end
  end
end
