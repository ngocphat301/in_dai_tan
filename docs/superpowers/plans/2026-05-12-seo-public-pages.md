# SEO trang công khai — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thêm `@seo` + partial meta (description, canonical, OG/Twitter) và JSON-LD (`@graph`: Organization, WebSite, + Article/Product theo trang) cho mọi trang HTML công khai theo spec `docs/superpowers/specs/2026-05-12-seo-public-pages-design.md`.

**Architecture:** `SeoHelper` cung cấp hàm dựng URL gốc (`https` + `CANONICAL_HOST` hoặc fallback `request`), cắt mô tả, URL ảnh OG mặc định; controller gán `@seo` và (tuỳ trang) `@seo_json_ld_extra` cho một khối `Product`/`BlogPosting`; layout `application` render `layouts/seo_tags` sau `yield :head`; gỡ `meta description` trùng trong các view đã có `content_for :head`.

**Tech stack:** Rails 8.1, Slim, ActiveStorage (ảnh blog/sản phẩm), Minitest `ActionDispatch::IntegrationTest`, fixtures.

---

## File map

| File | Vai trò |
|------|---------|
| `app/helpers/seo_helper.rb` | **Tạo** — truncate, `seo_site_origin`, `seo_current_canonical_url`, URL ảnh tuyệt đối cho blog/product, build hash JSON-LD graph |
| `app/views/layouts/_seo_tags.html.slim` | **Tạo** — canonical, meta description, robots noindex, OG, Twitter, một thẻ `script[type="application/ld+json"]` chứa `@graph` |
| `app/views/layouts/application.html.slim` | **Sửa** — `= render "layouts/seo_tags"` sau `yield :head`, cảnh báo log dev khi thiếu `@seo` |
| `app/controllers/application_controller.rb` | **Sửa** — `include SeoHelper` để action controller gọi `seo_*` khi gán `@seo` |
| `app/controllers/home_controller.rb` | **Sửa** — gán `@seo` sau `load_home_page_data` |
| `app/controllers/pages_controller.rb` | **Sửa** — `@seo` cho `about`, `contact` |
| `app/controllers/products_controller.rb` | **Sửa** — `@seo` index + show; show thêm `@seo_json_ld_extra` cho `Product` |
| `app/controllers/blog_posts_controller.rb` | **Sửa** — `@seo` cho `index`, `service_index`, `project_index`, `show`; show thêm `BlogPosting` |
| `app/controllers/searches_controller.rb` | **Sửa** — `@seo` tối thiểu + `noindex: true` |
| `app/views/blog_posts/show.html.slim` | **Sửa** — bỏ `content_for :head` meta description (đã nằm trong `_seo_tags`) |
| `app/views/pages/about.html.slim` | **Sửa** — bỏ block `content_for :head` meta |
| `app/views/pages/contact.html.slim` | **Sửa** — bỏ block `content_for :head` meta |
| `.env.production.example` | **Sửa** — thêm `CANONICAL_HOST=inantandai.com` và ghi chú |
| `test/fixtures/blog_posts.yml` | **Sửa** — thêm bài `publish` có `published_at` + `slug` cố định |
| `test/fixtures/products.yml` | **Sửa** — một bản ghi `published: true` |
| `test/controllers/seo_public_pages_test.rb` | **Tạo** — integration GET + assert_select |

---

### Task 1: `SeoHelper` — URL gốc, cắt mô tả, ảnh OG

**Files:**
- Create: `app/helpers/seo_helper.rb`

- [ ] **Step 1: Tạo helper đầy đủ**

```ruby
# frozen_string_literal: true

module SeoHelper
  include ApplicationHelper
  include ProductsHelper

  SEO_DESCRIPTION_MAX = 300

  def seo_truncate_description(text, max = SEO_DESCRIPTION_MAX)
    truncate(text.to_s.strip, length: max, omission: "…")
  end

  # https://inantandai.com hoặc http://localhost:3000 (dev) khi không có ENV.
  def seo_site_origin(request)
    host = ENV["CANONICAL_HOST"].presence
    if host
      "https://#{host}"
    else
      "#{request.scheme}://#{request.host_with_port}"
    end
  end

  def seo_current_canonical_url(request)
    "#{seo_site_origin(request)}#{request.fullpath}"
  end

  def seo_default_og_image_url(request)
    url = ENV["SEO_DEFAULT_OG_IMAGE_URL"].presence
    return url if url.present?

    site_brand_logo_url
  end

  # URL tuyệt đối cho avatar blog (ActiveStorage); fallback logo site.
  def seo_blog_og_image_url(blog_post, request)
    return seo_default_og_image_url(request) unless blog_post.avatar.attached?

    host = ENV["CANONICAL_HOST"].presence || request.host_with_port
    protocol = ENV["CANONICAL_HOST"].present? ? "https" : request.scheme
    Rails.application.routes.url_helpers.rails_blob_url(
      blog_post.avatar,
      host: host,
      protocol: protocol
    )
  rescue StandardError
    seo_default_og_image_url(request)
  end

  def seo_product_og_image_url(product, request)
    gal = product_gallery_items(product)
    first = gal.first
    return seo_default_og_image_url(request) unless first

    u = first[:url].to_s
    return u if u.start_with?("http://", "https://")

    "#{seo_site_origin(request)}#{u}"
  rescue StandardError
    seo_default_og_image_url(request)
  end
end
```

- [ ] **Step 2: Kiểm tra autoload**

Run: `cd /Users/its/Documents/Codes/in_dai_tan && bin/rails zeitwerk:check`

Expected: `All is good!` (hoặc thông báo zeitwerk hợp lệ)

- [ ] **Step 3:** (đã gộp vào commit Task 2 Step 4 — bỏ commit riêng Task 1 nếu làm liền một nhánh)

---

### Task 2: Partial `_seo_tags` + gọi từ layout

**Files:**
- Create: `app/views/layouts/_seo_tags.html.slim`
- Modify: `app/views/layouts/application.html.slim`

- [ ] **Step 1: Tạo partial**

Nội dung `app/views/layouts/_seo_tags.html.slim` (dựa vào `@seo` là `Hash` với symbol keys):

```slim
- seo = @seo || {}
- title = seo[:title].to_s
- desc = seo[:description].to_s
- canonical = seo[:canonical].to_s
- og_type = seo[:og_type].presence || "website"
- og_image = seo[:og_image].presence || seo_default_og_image_url(request)
- doc_title = "#{title} | In Tân Đại"
- if seo[:noindex]
  meta name="robots" content="noindex, nofollow"
meta name="description" content=desc
link rel="canonical" href=canonical
meta property="og:title" content=doc_title
meta property="og:description" content=desc
meta property="og:url" content=canonical
meta property="og:image" content=og_image
meta property="og:type" content=og_type
meta property="og:locale" content="vi_VN"
meta name="twitter:card" content="summary_large_image"
meta name="twitter:title" content=doc_title
meta name="twitter:description" content=desc
meta name="twitter:image" content=og_image
- graph = seo_json_ld_graph(seo, request: request)
- if graph.present?
  script type="application/ld+json" == json_ld_escape(graph)
```

**Step 1b:** Trong **cùng file** `app/helpers/seo_helper.rb` (cùng commit với Task 1 hoặc ngay trước khi render partial), thêm `seo_json_ld_graph` và `json_ld_escape`:

```ruby
  def json_ld_escape(data)
    raw(ERB::Util.json_escape(data.to_json))
  end

  def seo_json_ld_graph(seo, request:)
    origin = seo_site_origin(request)
    site_name = "In Tân Đại"
    org = {
      "@type" => "Organization",
      "name" => "Công ty TNHH tổng hợp sản xuất và thương mại Tân Đại",
      "alternateName" => site_name,
      "url" => origin,
      "logo" => seo_default_og_image_url(request),
      "telephone" => "+84-#{social_hotline.sub(/\A0/, "")}",
      "email" => "inantandai@gmail.com",
      "address" => {
        "@type" => "PostalAddress",
        "streetAddress" => "Số 39 Xuân Khôi, Cự Khối, Long Biên",
        "addressLocality" => "Hà Nội",
        "addressCountry" => "VN"
      }
    }
    web = {
      "@type" => "WebSite",
      "name" => site_name,
      "url" => origin
    }
    extra = @seo_json_ld_extra
    list = [ org, web ]
    list << extra if extra.present?
    { "@context" => "https://schema.org", "@graph" => list }
  end
```

`@seo_json_ld_extra` do controller gán (Hash một entity); `BlogPosting` / `Product` build ở Task 3.

- [ ] **Step 2: Sửa layout** — trong `app/views/layouts/application.html.slim`, sau dòng `= yield :head`, thêm:

```slim
- if @seo.present?
  = render "layouts/seo_tags"
- elsif Rails.env.development?
  - Rails.logger.warn("[seo] missing @seo for #{controller_path}##{action_name}")
```

- [ ] **Step 3: Chạy smoke test**

Run: `cd /Users/its/Documents/Codes/in_dai_tan && bin/rails test test/controllers/robots_controller_test.rb`

Expected: PASS

- [ ] **Step 4: Commit** (một commit gồm helper đầy đủ + partial + layout)

```bash
git add app/helpers/seo_helper.rb app/views/layouts/_seo_tags.html.slim app/views/layouts/application.html.slim
git commit -m "feat(seo): SeoHelper, layout SEO tags and JSON-LD @graph"
```

---

### Task 3: Controller gán `@seo` (và `@seo_json_ld_extra` khi cần)

**Files:**
- Modify: `app/controllers/home_controller.rb`
- Modify: `app/controllers/pages_controller.rb`
- Modify: `app/controllers/products_controller.rb`
- Modify: `app/controllers/blog_posts_controller.rb`
- Modify: `app/controllers/searches_controller.rb`

Include `SeoHelper` trong controller qua `helpers` — trong controller dùng `helpers.seo_site_origin(request)` hoặc `include SeoHelper` trong `ApplicationController` với `helper_method` — **đơn giản nhất:** `include SeoHelper` trong `ApplicationController` (chỉ method instance cho controller).

Thêm vào `app/controllers/application_controller.rb`:

```ruby
include SeoHelper
```

- [ ] **Step 1: `HomeController#index`** — sau `load_home_page_data`:

```ruby
@seo = {
  title: "Trang chủ",
  description: seo_truncate_description(
    "In Tân Đại — xưởng in offset, hộp giấy, bao bì và ấn phẩm thương mại tại Hà Nội. Báo giá minh bạch, đúng tiến độ."
  ),
  canonical: seo_current_canonical_url(request),
  og_type: "website",
  og_image: seo_default_og_image_url(request)
}
```

- [ ] **Step 2: `PagesController`** — `about`:

```ruby
@seo = {
  title: "Giới thiệu",
  description: seo_truncate_description("Giới thiệu Công ty Bao bì In Tân Đại — triết lý kinh doanh, năng lực sản xuất, công nghệ in ấn và đội ngũ."),
  canonical: seo_current_canonical_url(request),
  og_type: "website",
  og_image: seo_default_og_image_url(request)
}
```

`contact` tương tự với description chuỗi hiện có trong `contact.html.slim` (hotline trong copy trang: dùng đúng nội dung đang hiển thị).

- [ ] **Step 3: `ProductsController#index`**

```ruby
@seo = {
  title: "Sản phẩm",
  description: seo_truncate_description("Bài giới thiệu bao bì và giải pháp in — danh mục blog loại Sản phẩm tại In Tân Đại."),
  canonical: seo_current_canonical_url(request),
  og_type: "website",
  og_image: seo_default_og_image_url(request)
}
```

**Lưu ý phân trang:** `request.fullpath` đã gồm `?page=2` → canonical đúng theo spec (self URL).

- [ ] **Step 4: `ProductsController#show`**

```ruby
desc = @product.description.to_s.strip.presence || "#{@product.name} — báo giá in ấn tại In Tân Đại."
@seo = {
  title: @product.name,
  description: seo_truncate_description(desc),
  canonical: seo_current_canonical_url(request),
  og_type: "product",
  og_image: seo_product_og_image_url(@product, request)
}
@seo_json_ld_extra = {
  "@type" => "Product",
  "name" => @product.name,
  "description" => seo_truncate_description(desc, 500),
  "image" => product_gallery_items(@product).map { |i| i[:url].to_s.start_with?("http") ? i[:url] : "#{seo_site_origin(request)}#{i[:url]}" },
  "offers" => {
    "@type" => "Offer",
    "priceCurrency" => "VND",
    "price" => @product.sale_price_vnd.to_i,
    "availability" => "https://schema.org/InStock",
    "url" => seo_current_canonical_url(request)
  }
}
```

- [ ] **Step 5: `BlogPostsController`** — mỗi action list:

`index`: title `@blog_list_title`, description cố định cho hub tin; `canonical: seo_current_canonical_url(request)`; `og_image`: nếu `@featured_post` có avatar thì `seo_blog_og_image_url(@featured_post, request)` else default.

`service_index` / `project_index`: description khác nhau một dòng mỗi loại.

`show`:

```ruby
title = @blog_post.meta_title.presence || @blog_post.title
desc = @blog_post.meta_description.presence || @blog_post.excerpt.to_s
@seo = {
  title: title,
  description: seo_truncate_description(desc),
  canonical: seo_current_canonical_url(request),
  og_type: "article",
  og_image: seo_blog_og_image_url(@blog_post, request)
}
canonical = @seo[:canonical]
published = @blog_post.published_at
@seo_json_ld_extra = {
  "@type" => "BlogPosting",
  "headline" => @blog_post.title,
  "description" => seo_truncate_description(desc, 500),
  "url" => canonical,
  "datePublished" => published&.iso8601,
  "image" => (seo_blog_og_image_url(@blog_post, request) if @blog_post.avatar.attached?)
}.compact
```

(`seo_current_canonical_url` đã gồm query `news_context` nếu có.)

- [ ] **Step 6: `SearchesController#index`**

```ruby
@seo = {
  title: "Tìm kiếm",
  description: "Kết quả tìm kiếm trên In Tân Đại.",
  canonical: seo_current_canonical_url(request),
  og_type: "website",
  og_image: seo_default_og_image_url(request),
  noindex: true
}
```

- [ ] **Step 7: Commit**

```bash
git add app/controllers/application_controller.rb app/controllers/home_controller.rb app/controllers/pages_controller.rb app/controllers/products_controller.rb app/controllers/blog_posts_controller.rb app/controllers/searches_controller.rb
git commit -m "feat(seo): assign @seo and JSON-LD extras on public controllers"
```

---

### Task 4: Gỡ meta description trùng trong view

**Files:**
- Modify: `app/views/blog_posts/show.html.slim`
- Modify: `app/views/pages/about.html.slim`
- Modify: `app/views/pages/contact.html.slim`

- [ ] **Step 1:** Xóa các dòng `- content_for :head do` / `meta name="description"` tương ứng; **giữ** `content_for :title` trên blog show.

- [ ] **Step 2: Commit**

```bash
git add app/views/blog_posts/show.html.slim app/views/pages/about.html.slim app/views/pages/contact.html.slim
git commit -m "refactor(seo): remove duplicate meta description from views"
```

---

### Task 5: ENV mẫu

**Files:**
- Modify: `.env.production.example`

- [ ] **Step 1:** Thêm section:

```
# SEO — host chuẩn cho canonical / OG URL (không gồm https://)
CANONICAL_HOST=inantandai.com
# Tuỳ chọn: ảnh mặc định khi trang không có ảnh (URL tuyệt đối)
# SEO_DEFAULT_OG_IMAGE_URL=https://...
```

(`SeoHelper` đã `include ApplicationHelper` + `ProductsHelper` ở Task 1.)

- [ ] **Step 2: Commit**

```bash
git add .env.production.example
git commit -m "chore(seo): document CANONICAL_HOST in production env example"
```

---

### Task 6: Fixtures + `test/controllers/seo_public_pages_test.rb`

**Files:**
- Modify: `test/fixtures/blog_posts.yml`
- Modify: `test/fixtures/products.yml`
- Create: `test/controllers/seo_public_pages_test.rb`

- [ ] **Step 1: Fixture blog đã publish**

Thêm vào `test/fixtures/blog_posts.yml` (dùng thời điểm cố định ERB):

```yaml
published_news:
  title: "Tin SEO fixture"
  slug: published-seo-news
  excerpt: "Mô tả ngắn fixture cho SEO."
  meta_title: "Meta title fixture"
  meta_description: "Meta description fixture cho bài tin."
  status: publish
  published_at: <%= 2.days.ago.to_fs(:db) %>
  user: one
  category: news
```

- [ ] **Step 2: Fixture product published**

Thêm:

```yaml
published_product:
  name: "Sản phẩm SEO fixture"
  description: "Mô tả sản phẩm fixture."
  original_price_vnd: 100000
  sale_price_vnd: 50000
  published: true
  product_category: one
```

- [ ] **Step 3: Viết test**

`test/controllers/seo_public_pages_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class SeoPublicPagesTest < ActionDispatch::IntegrationTest
  test "root includes canonical and og:title" do
    get root_url
    assert_response :success
    assert_select 'link[rel="canonical"][href^="http"]', count: 1
    assert_select 'meta[property="og:title"][content*="Trang chủ"]', count: 1
    assert_select 'script[type="application/ld+json"]', minimum: 1
  end

  test "blog show includes BlogPosting in JSON-LD" do
    get blog_post_url("published-seo-news")
    assert_response :success
    assert_select 'meta[name="description"][content*="fixture"]', count: 1
    body = response.body
    assert_includes body, "BlogPosting"
  end

  test "product show includes Product in JSON-LD" do
    p = products(:published_product)
    get product_url(p)
    assert_response :success
    assert_includes response.body, '"@type":"Product"'
  end
end
```

Điều chỉnh `blog_post_url` / `product_url` — trong integration test mặc định host `www.example.com`; đảm bảo `canonical` assert không cứng `inantandai.com` nếu ENV trống trong test.

- [ ] **Step 4: Chạy test**

Run: `cd /Users/its/Documents/Codes/in_dai_tan && bin/rails test test/controllers/seo_public_pages_test.rb`

Expected: 3 runs, 0 failures

- [ ] **Step 5: Chạy full test**

Run: `bin/rails test`

Expected: 0 failures

- [ ] **Step 6: Commit**

```bash
git add test/fixtures/blog_posts.yml test/fixtures/products.yml test/controllers/seo_public_pages_test.rb
git commit -m "test(seo): assert canonical, OG and JSON-LD on key pages"
```

---

### Task 7: RuboCop (tuỳ repo)

- [ ] **Step 1:** Run: `bin/rubocop app/helpers/seo_helper.rb app/controllers/home_controller.rb app/controllers/pages_controller.rb app/controllers/products_controller.rb app/controllers/blog_posts_controller.rb app/controllers/searches_controller.rb`

Expected: no offenses (sửa nếu có)

- [ ] **Step 2: Commit** (nếu có sửa style)

```bash
git add -A && git commit -m "style(seo): rubocop fixes for SEO files"
```

---

## Spec coverage checklist (self-review)

| Yêu cầu spec | Task |
|---------------|------|
| `@seo` hash, description, canonical, og_type, og_image, noindex | Task 2–3 |
| OG + Twitter | Task 2 |
| Organization + WebSite, không SearchAction | Task 2 (`seo_json_ld_graph`) |
| BlogPosting / Product JSON-LD | Task 3 `@seo_json_ld_extra` |
| Không trùng meta description view | Task 4 |
| CANONICAL_HOST ENV | Task 5 |
| Integration test home + blog + product | Task 6 |
| Giữ ItemList quy mô xưởng | Không đụng `home/_factory_scale` — vẫn `content_for :head` script riêng; partial SEO thêm meta — **thứ tự head:** `yield :head` trước (chứa ItemList), sau đó `_seo_tags` — OK |

**Placeholder scan:** Không dùng TBD trong plan; điện thoại JSON-LD dùng `social_hotline` — khớp site, không bịa số mới.

---

**Plan complete and saved to `docs/superpowers/plans/2026-05-12-seo-public-pages.md`. Two execution options:**

1. **Subagent-Driven (recommended)** — Mỗi task một subagent mới, review giữa các task  
2. **Inline Execution** — Làm tuần tự trong session hiện tại theo checkpoint

**Bạn muốn cách nào?** (Trả lời `1` hoặc `2`; nếu không chỉ rõ, có thể bắt đầu inline ngay trong repo này.)
