# frozen_string_literal: true

module Breadcrumbs
  extend ActiveSupport::Concern

  private

  def crumb_root
    { label: "Trang chủ", path: root_path }
  end

  def crumb_current(label)
    { label:, path: nil }
  end
end
