# frozen_string_literal: true

# Phân trang và sắp xếp cột (?sort=&dir=) cho màn admin index.
module AdminPaginatable
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 20

  private

  def admin_paginate(scope, per: DEFAULT_PER_PAGE)
    per = per.to_i
    per = DEFAULT_PER_PAGE if per < 1
    total_count = scope.count
    total_pages = [ (total_count.to_f / per).ceil, 1 ].max
    page = [ params[:page].to_i, 1 ].max
    page = [ page, total_pages ].min
    records = scope.offset((page - 1) * per).limit(per)
    { records: records, page: page, per: per, total_pages: total_pages, total_count: total_count }
  end

  def apply_admin_order(scope, allowed:, default:)
    col = allowed.include?(params[:sort].to_s) ? params[:sort].to_s : default
    dir = params[:dir] == "asc" ? :asc : :desc
    scope.order(col => dir)
  end
end
