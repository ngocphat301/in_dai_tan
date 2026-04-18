# frozen_string_literal: true

# Khớp từ khóa có/không dấu (PostgreSQL extension unaccent).
module AccentInsensitiveCatalogMatch
  extend ActiveSupport::Concern

  module ClassMethods
    def accent_insensitive_columns_match(query, columns)
      q = query.to_s.strip.downcase
      return none if q.blank?

      like = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
      tn = connection.quote_table_name(table_name)
      fragments = columns.map do |col|
        cn = connection.quote_column_name(col)
        "unaccent(lower(COALESCE(#{tn}.#{cn}, ''))) ILIKE unaccent(lower(?::text))"
      end
      where([ fragments.join(" OR "), *([ like ] * columns.size) ])
    end
  end
end
