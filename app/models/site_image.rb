# frozen_string_literal: true

# Ảnh dùng cho site (banner trang chủ, poster, quảng cáo…)
class SiteImage < ApplicationRecord
  has_one_attached :file
  has_one_attached :mobile_file

  attribute :category, :string, default: "banner"

  enum :category, {
    banner: "banner",
    poster: "poster",
    partner: "partner",
    factory_scale: "factory_scale",
    customer_feedback: "customer_feedback",
    home_video: "home_video",
  }, default: :banner

  CATEGORY_LABELS = {
    "banner" => "Banner (slide)",
    "poster" => "Poster",
    "partner" => "Đối tác (logo trang chủ)",
    "factory_scale" => "Quy mô (xưởng in)",
    "customer_feedback" => "Phản hồi khách hàng (trang chủ)",
    "home_video" => "Video YouTube (trang chủ)",
  }.freeze

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :file, presence: true, on: :create, unless: -> { home_video? || (factory_scale? && youtube_video?) }
  validate :home_video_link_required, if: :home_video?
  validate :file_must_be_image, if: -> { file.attached? }

  def youtube_video_id
    s = link_url.to_s.strip
    return nil if s.blank?

    if (m = s.match(%r{youtu\.be/([A-Za-z0-9_-]{6,})}))
      return m[1]
    end

    uri = URI.parse(s)
    if uri.host&.include?("youtube.com")
      if uri.path == "/watch"
        return URI.decode_www_form(uri.query.to_s).to_h["v"].presence
      end
      if (m = uri.path.match(%r{/embed/([A-Za-z0-9_-]{6,})}))
        return m[1]
      end
      if (m = uri.path.match(%r{/shorts/([A-Za-z0-9_-]{6,})}))
        return m[1]
      end
    end
    nil
  rescue URI::InvalidURIError
    nil
  end

  def youtube_video?
    youtube_video_id.present?
  end

  scope :ordered, -> { order(:position, :id) }
  scope :published_only, -> { where(published: true) }
  scope :for_home_banner, -> { banner.published_only.ordered }
  scope :for_home_partners, -> { partner.published_only.ordered }
  scope :for_home_factory_scale, -> { factory_scale.published_only.ordered }
  scope :for_home_customer_feedback, -> { customer_feedback.published_only.ordered }
  scope :for_home_video, -> { home_video.published_only.ordered }

  def self.category_options_for_select
    [
      [ "Banner (slide trang chủ)", "banner" ],
      [ "Poster", "poster" ],
      [ "Đối tác (logo hàng ngang)", "partner" ],
      [ "Quy mô (lưới trang chủ)", "factory_scale" ],
      [ "Phản hồi khách hàng", "customer_feedback" ],
      [ "Video YouTube (URL trong liên kết)", "home_video" ],
    ]
  end

  def self.category_label_for(key)
    CATEGORY_LABELS[key.to_s] || key.to_s.humanize
  end

  private

  def home_video_link_required
    return if link_url.present?

    errors.add(:link_url, "bắt buộc cho video YouTube (dán link watch hoặc youtu.be)")
  end

  def file_must_be_image
    type = file.content_type
    return if type.blank?

    return if type.start_with?("image/")

    errors.add(:file, "phải là tệp ảnh")
  end
end
