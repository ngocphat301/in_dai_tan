# frozen_string_literal: true

module PaginatedCatalog
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 12

  private

  # Trả về { records:, page:, per:, total_pages:, total_count: }
  def paginate_scope(scope, per: DEFAULT_PER_PAGE)
    per = per.to_i
    per = DEFAULT_PER_PAGE if per < 1
    total_count = scope.count
    total_pages = [ (total_count.to_f / per).ceil, 1 ].max
    page = [ params[:page].to_i, 1 ].max
    page = [ page, total_pages ].min
    records = scope.offset((page - 1) * per).limit(per)
    { records: records, page: page, per: per, total_pages: total_pages, total_count: total_count }
  end
end
