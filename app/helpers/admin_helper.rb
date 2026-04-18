# frozen_string_literal: true

module AdminHelper
  # URL giữ các tham số lọc hiện tại, bỏ ?q= (nút «Xóa tìm»).
  def admin_clear_search_url
    qp = request.query_parameters.except("q").reject { |_, v| v.blank? }
    qstr = qp.to_query
    qstr.present? ? "#{request.path}?#{qstr}" : request.path
  end

  def admin_page_path(page)
    qp = request.query_parameters.merge("page" => page)
    "#{request.path}?#{qp.to_query}"
  end

  # Tiêu đề cột có thể sắp xếp — giữ q, sort, dir, filter…; icon sort + trạng thái khi sort mặc định không có trong URL.
  def admin_sort_link(column, label)
    col = column.to_s
    default_col = (@admin_default_sort.presence || "updated_at")
    default_dir = %w[asc desc].include?(@admin_default_sort_dir.to_s) ? @admin_default_sort_dir.to_s : "desc"

    req_sort = params[:sort].to_s
    req_dir = params[:dir] == "asc" ? "asc" : "desc"

    on_this_column = (req_sort == col) || (req_sort.blank? && col == default_col)

    new_dir =
      if on_this_column
        cur = req_sort.present? ? req_dir : default_dir
        cur == "asc" ? "desc" : "asc"
      else
        "asc"
      end

    qp = request.query_parameters.except("page").merge("sort" => col, "dir" => new_dir)
    href = "#{request.path}?#{qp.to_query}"

    icon_state =
      if on_this_column
        (req_sort.present? ? req_dir : default_dir) == "asc" ? :asc : :desc
      else
        :none
      end

    active = on_this_column

    link_to(href, class: [ "admin-th-sort", ("is-active" if active) ].compact.join(" ")) do
      safe_join([
        content_tag(:span, label, class: "admin-th-sort__label"),
        admin_sort_icons(icon_state)
      ])
    end
  end

  def admin_icon_edit_link(url, title: "Sửa")
    link_to(
      url,
      class: "admin-icon-btn admin-icon-btn--edit",
      aria: { label: title },
      title: title
    ) { admin_icon_pencil_svg }
  end

  def admin_icon_destroy_link(url, confirm:, title: "Xóa")
    link_to(
      url,
      class: "admin-icon-btn admin-icon-btn--danger",
      aria: { label: title },
      title: title,
      data: { turbo_method: :delete, turbo_confirm: confirm }
    ) { admin_icon_trash_svg }
  end

  # Tham số URL chung cho admin danh sách bài (giữ q, sort, dir khi đổi tab danh mục).
  def admin_blog_posts_index_params
    h = {}
    h[:q] = params[:q] if params[:q].present?
    h[:sort] = params[:sort] if params[:sort].present?
    h[:dir] = params[:dir] if params[:dir].present?
    h
  end

  # Mở bài công khai (tab mới).
  def admin_icon_public_view_link(url, title: "Xem công khai")
    link_to(
      url,
      target: "_blank",
      rel: "noopener",
      class: "admin-icon-btn admin-icon-btn--view",
      aria: { label: title },
      title: title
    ) { admin_icon_external_svg }
  end

  private

  def admin_sort_icons(state)
    content_tag(:span, class: "admin-sort-icons", aria: { hidden: true }) do
      case state
      when :asc
        admin_sort_svg_single(:up)
      when :desc
        admin_sort_svg_single(:down)
      else
        admin_sort_svg_both
      end
    end
  end

  def admin_sort_svg_single(dir)
    if dir == :up
      raw(
        '<svg class="admin-sort-ico" width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path d="M6 2.5L10 7H2L6 2.5Z" fill="currentColor"/></svg>'
      )
    else
      raw(
        '<svg class="admin-sort-ico" width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path d="M6 9.5L2 5h8L6 9.5Z" fill="currentColor"/></svg>'
      )
    end
  end

  def admin_sort_svg_both
    raw(
      '<svg class="admin-sort-ico admin-sort-ico--both" width="12" height="14" viewBox="0 0 12 14" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' \
      '<path d="M6 1.5L9.5 5.5H2.5L6 1.5Z" fill="currentColor" opacity="0.35"/>' \
      '<path d="M6 12.5L2.5 8.5h7L6 12.5Z" fill="currentColor" opacity="0.35"/></svg>'
    )
  end

  def admin_icon_pencil_svg
    raw(
      '<svg class="admin-ico" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' \
      '<path d="M4 20h3.5l10-10L14 6.5 4 16.5V20z" stroke="currentColor" stroke-width="1.75" stroke-linejoin="round"/>' \
      '<path d="M14.5 5L19 9.5" stroke="currentColor" stroke-width="1.75" stroke-linecap="round"/></svg>'
    )
  end

  def admin_icon_trash_svg
    raw(
      '<svg class="admin-ico" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' \
      '<path d="M9 9v8M15 9v8" stroke="currentColor" stroke-width="1.75" stroke-linecap="round"/>' \
      '<path d="M5 7h14M10 7V5h4v2M8 7h8v12a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2V7z" stroke="currentColor" stroke-width="1.75" stroke-linejoin="round"/></svg>'
    )
  end

  def admin_icon_external_svg
    raw(
      '<svg class="admin-ico" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' \
      '<path d="M14 3h7v7" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>' \
      '<path d="M10 14L21 3" stroke="currentColor" stroke-width="1.75" stroke-linecap="round"/>' \
      '<path d="M21 14v6a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h6" stroke="currentColor" stroke-width="1.75" stroke-linecap="round"/></svg>'
    )
  end
end
