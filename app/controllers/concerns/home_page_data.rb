# frozen_string_literal: true

module HomePageData
  extend ActiveSupport::Concern

  private

  def load_home_page_data
    @banner_slides = SiteImage.with_attached_file.for_home_banner
    @partner_images = SiteImage.for_home_partners.includes(file_attachment: :blob).limit(40)

    news_cat = BlogCategory.find_by(kind: :news) || BlogCategory.find_by(slug: "news")
    @news_blog_posts = if news_cat
      BlogPost.published_now
        .where(blog_category: news_cat)
        .includes(:blog_category, { avatar_attachment: :blob })
        .limit(12)
    else
      BlogPost.none
    end

    @featured_blog_posts = if news_cat
      BlogPost.published_now
        .where(blog_category: news_cat)
        .includes(:blog_category, { avatar_attachment: :blob })
        .order(published_at: :desc)
        .limit(8)
    else
      BlogPost.none
    end

    project_categories = BlogCategory.where(kind: :project)
    @project_blog_posts = if project_categories.any?
      BlogPost.published_now
        .where(blog_category: project_categories)
        .includes(:blog_category, { avatar_attachment: :blob })
        .order(published_at: :desc)
        .limit(200)
    else
      BlogPost.none
    end

    scale_cat = BlogCategory.find_by(kind: :factory_scale)
    if scale_cat
      scale_scope = BlogPost.published_now
        .where(blog_category: scale_cat)
        .includes(:blog_category, { avatar_attachment: :blob })
        .order(published_at: :desc)
      @factory_scale_mosaic_posts = scale_scope.limit(6).to_a
    else
      @factory_scale_mosaic_posts = []
    end

    cats = ProductCategory.ordered.includes(blog_post: [:blog_category, { avatar_attachment: :blob }]).to_a
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
