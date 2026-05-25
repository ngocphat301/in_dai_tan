# frozen_string_literal: true

# Cho phép bảng HTML và thuộc tính rel trên liên kết trong nội dung Action Text (blog admin).
Rails.application.config.after_initialize do
  sanitizer = ActionText::ContentHelper.sanitizer
  ActionText::ContentHelper.allowed_tags =
    sanitizer.class.allowed_tags + [ActionText::Attachment.tag_name, "figure", "figcaption", "table", "thead", "tbody", "tr", "th", "td"]
  ActionText::ContentHelper.allowed_attributes =
    sanitizer.class.allowed_attributes + ActionText::Attachment::ATTRIBUTES + %w[rel]
end
