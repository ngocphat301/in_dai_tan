# frozen_string_literal: true

namespace :search do
  desc "Tìm kiếm dùng PostgreSQL (pg_search); không cần reindex Elasticsearch"
  task reindex: :environment do
    puts "[search] Đã chuyển sang pg_search — không có bước reindex."
  end
end
