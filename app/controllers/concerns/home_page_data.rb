# frozen_string_literal: true

module HomePageData
  extend ActiveSupport::Concern

  private

  def load_home_page_data
    @banner_slides = SiteImage.with_attached_file.for_home_banner.includes(file_attachment: :blob).load
    @partner_images = SiteImage.for_home_partners.includes(file_attachment: :blob).limit(6)
    @customer_feedback_images = SiteImage.for_home_customer_feedback
      .includes(file_attachment: :blob)
      .limit(3)
      .load
    @home_video = SiteImage.for_home_video.includes(file_attachment: :blob).first
    @factory_scale_site_images = SiteImage.with_attached_file.for_home_factory_scale
      .includes(file_attachment: :blob)
      .limit(6)
      .load

    @featured_blog_posts = BlogPost.published_now
      .where(category: :news)
      .includes({ avatar_attachment: :blob })
      .order(published_at: :desc)
      .limit(4)

    @home_completed_projects = BlogPost.published_now
      .where(category: :project)
      .includes({ avatar_attachment: :blob })
      .order(published_at: :desc)
      .limit(4)
      .to_a

    scale_scope = BlogPost.published_now
      .where(category: :factory_scale)
      .includes({ avatar_attachment: :blob })
      .order(published_at: :desc)
    @factory_scale_mosaic_posts = scale_scope.limit(6).to_a

    cats = ProductCategory.ordered.includes(blog_post: { avatar_attachment: :blob }).to_a
    @home_service_frames = cats.map do |cat|
      post = cat.blog_post
      if post&.published_for_public?
        { type: :blog, post: post }
      else
        { type: :category, category: cat }
      end
    end
  end
end
