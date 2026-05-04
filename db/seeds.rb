# frozen_string_literal: true

admin = User.find_or_initialize_by(email: "admin@example.com")
admin.assign_attributes(
  password: "password123",
  password_confirmation: "password123",
  role: :admin
)
admin.save!

User.find_or_initialize_by(email: "user@example.com").tap do |u|
  u.assign_attributes(password: "password123", password_confirmation: "password123", role: :member)
  u.save!
end

# Danh mục sản phẩm (13 loại hộp/túi/phong bì):
# - KHÔNG nằm trong schema.rb (schema chỉ mô tả cột/bảng).
# - Migration 20260414120001 chỉ chèn 4 bản ghi cũ khi migrate; 13 mục dưới đây chỉ được tạo khi chạy: bin/rails db:seed
# - Nếu DB tạo bằng db:schema:load thì bảng product_categories rỗng cho đến khi seed.
[
  [ "Hộp nắp cài đáy chéo", "hop-nap-cai-day-cheo", 0 ],
  [ "Hộp nắp cài 2 đầu", "hop-nap-cai-2-dau", 1 ],
  [ "Hộp nắp gập cuộn", "hop-nap-gap-cuon", 2 ],
  [ "Hộp âm dương", "hop-am-duong", 3 ],
  [ "Hộp đáy chéo nắp quai xách", "hop-day-cheo-nap-quai-xach", 4 ],
  [ "Hộp đối", "hop-doi", 5 ],
  [ "Hộp nắp chồng", "hop-nap-chong", 6 ],
  [ "Hộp pizza", "hop-pizza", 7 ],
  [ "Hộp giày", "hop-giay", 8 ],
  [ "Hộp rút", "hop-rut", 9 ],
  [ "Phong bì", "phong-bi", 10 ],
  [ "Túi giấy", "tui-giay", 11 ]
].each do |name, slug, position|
  ProductCategory.find_or_initialize_by(slug: slug).tap do |c|
    c.assign_attributes(name: name, position: position)
    c.save!
  end
end
puts "[seeds] Danh mục sản phẩm: #{ProductCategory.count} bản ghi (mong đợi: 13+ nếu DB đã có bản ghi migration cũ)."

default_product_category = ProductCategory.find_by!(slug: "hop-nap-cai-day-cheo")

demo = Product.find_or_initialize_by(name: "Sản phẩm mẫu")
demo.assign_attributes(
  product_category: default_product_category,
  description: "Mô tả ngắn cho sản phẩm demo. Bạn có thể sửa trong quản trị.",
  original_price_vnd: 249_000,
  sale_price_vnd: 199_000,
  published: true
)
demo.save!

icon = Rails.root.join("public/icon.svg")
if demo.images.empty? && File.exist?(icon)
  img = demo.images.build(caption: "Ảnh demo", position: 0)
  img.file.attach(io: File.open(icon), filename: "demo.svg", content_type: "image/svg+xml")
  img.save!
end

Product.find_or_initialize_by(name: "Sản phẩm nháp").tap do |p|
  p.assign_attributes(
    product_category: default_product_category,
    description: "Chưa hiển thị ra trang chủ.",
    original_price_vnd: 0,
    sale_price_vnd: 50_000,
    published: false
  )
  p.save!
end

BlogPost.find_or_initialize_by(slug: "uu-dai-in-an-thang-dau").tap do |post|
  post.assign_attributes(
    user: admin,
    category: :ads,
    title: "Ưu đãi in ấn — chương trình khuyến mãi",
    excerpt: "Xem chi tiết ưu đãi, điều kiện áp dụng và báo giá nhanh.",
    meta_title: "Ưu đãi in ấn | In Tân Đại",
    meta_description: "Chương trình ưu đãi in ấn — liên hệ tư vấn.",
    status: :publish,
    published_at: Time.zone.parse("2026-04-01 08:00")
  )
  post.save!
  if post.body.blank?
    post.body = <<~HTML
      <p>Đây là trang nội dung chi tiết khi khách bấm vào ảnh quảng cáo trên popup. Bạn có thể chỉnh trong quản trị.</p>
      <p>Ưu đãi minh họa: giảm phí thiết kế, in thử mẫu, giao hàng nội thành…</p>
    HTML
    post.save!
  end
end

require_relative "seeds/blog_entries"

def seed_attach_blog_avatar(post, filename)
  path = Rails.root.join("db/seed_assets/blog", filename)
  return unless File.exist?(path)

  File.open(path, "rb") do |io|
    post.avatar.attach(io: io, filename: filename, content_type: "image/jpeg")
  end
end

BlogEntries::SEED_BLOG_POSTS.each do |row|
  category = case row[:kind]
  when :news then :news
  when :product then :product
  when :service then :service
  when :project then :project
  when :factory_scale then :factory_scale
  when :partners then :partners
  end
  next unless category

  tag_seed = row[:tag_list]

  BlogPost.find_or_initialize_by(slug: row[:slug]).tap do |post|
    post.assign_attributes(
      user: admin,
      category: category,
      title: row[:title],
      excerpt: row[:excerpt],
      meta_title: row[:meta_title],
      meta_description: row[:meta_description],
      status: :publish,
      published_at: row[:published_at]
    )
    post.save!
    post.body = row[:body]
    post.tag_list = tag_seed if tag_seed.present?
    post.save!
    post.avatar.purge if post.avatar.attached?
    seed_attach_blog_avatar(post, row[:image])
  end
end

ads_avatar = Rails.root.join("db/seed_assets/blog", "img_23.jpg")
BlogPost.find_by(slug: "uu-dai-in-an-thang-dau")&.tap do |post|
  next unless File.exist?(ads_avatar)

  post.avatar.purge if post.avatar.attached?
  seed_attach_blog_avatar(post, "img_23.jpg")
end

n = BlogEntries::SEED_BLOG_POSTS.size
puts "[seeds] Bài blog seed: #{n} bài (#{BlogEntries::SEED_BLOG_POSTS.count { |r| r[:kind] == :service }} dịch vụ, #{BlogEntries::SEED_BLOG_POSTS.count { |r| r[:kind] == :product }} sản phẩm, #{BlogEntries::SEED_BLOG_POSTS.count { |r| r[:kind] == :news }} tin tức, #{BlogEntries::SEED_BLOG_POSTS.count { |r| r[:kind] == :project }} dự án, #{BlogEntries::SEED_BLOG_POSTS.count { |r| r[:kind] == :factory_scale }} quy mô). Ảnh: db/seed_assets/blog/"

# Trang chính sách — slug cố định (footer + SEO); danh mục «Tin tức»
[
  {
    slug: "chinh-sach-thanh-toan",
    title: "Chính Sách Thanh Toán",
    excerpt: "Hình thức thanh toán, thời hạn và điều khoản áp dụng.",
    body: <<~HTML
      <p>Nội dung minh họa — vui lòng cập nhật đầy đủ trong quản trị.</p>
      <h3>Phương thức thanh toán</h3>
      <p>Chuyển khoản ngân hàng, tiền mặt khi nhận hàng (COD), hoặc các hình thức thỏa thuận khi ký hợp đồng.</p>
      <h3>Thời hạn thanh toán</h3>
      <p>Thanh toán theo tiến độ đơn hàng hoặc một lần tùy thỏa thuận báo giá.</p>
    HTML
  },
  {
    slug: "chinh-sach-doi-tra",
    title: "Chính Sách Đổi Trả",
    excerpt: "Điều kiện đổi trả, hoàn tiền và xử lý sai lệch sản phẩm.",
    body: <<~HTML
      <p>Nội dung minh họa — vui lòng cập nhật đầy đủ trong quản trị.</p>
      <h3>Điều kiện đổi trả</h3>
      <p>Sản phẩm lỗi in ấn, sai quy cách so với đơn đặt hàng đã xác nhận — liên hệ trong thời gian quy định.</p>
      <h3>Hoàn tiền</h3>
      <p>Áp dụng theo thỏa thuận hợp đồng và tình trạng sản phẩm khi nhận.</p>
    HTML
  },
  {
    slug: "chinh-sach-giao-hang",
    title: "Chính Sách Giao Hàng",
    excerpt: "Phạm vi giao hàng, phí vận chuyển và thời gian giao dự kiến.",
    body: <<~HTML
      <p>Nội dung minh họa — vui lòng cập nhật đầy đủ trong quản trị.</p>
      <h3>Phạm vi giao hàng</h3>
      <p>Giao nội thành, liên tỉnh hoặc nhận tại xưởng — theo thỏa thuận từng đơn.</p>
      <h3>Phí vận chuyển</h3>
      <p>Tính theo khối lượng, khoảng cách hoặc miễn phí theo chương trình khuyến mãi.</p>
    HTML
  }
].each do |row|
  BlogPost.find_or_initialize_by(slug: row[:slug]).tap do |post|
    post.assign_attributes(
      user: admin,
      category: :news,
      title: row[:title],
      excerpt: row[:excerpt],
      meta_title: "#{row[:title]} | In Tân Đại",
      meta_description: row[:excerpt],
      status: :publish,
      published_at: Time.zone.parse("2026-01-01 10:00")
    )
    post.save!
    post.body = row[:body]
    post.save!
  end
end
puts "[seeds] Chính sách (blog): chinh-sach-thanh-toan, chinh-sach-doi-tra, chinh-sach-giao-hang"

# Gắn bài blog dịch vụ demo với một danh mục — menu «Dịch vụ in» bấm vào sẽ mở bài (có thể đổi trong quản trị)
demo_blog = BlogPost.find_by(slug: "in-sach-theo-yeu-cau")
demo_cat = ProductCategory.find_by(slug: "hop-nap-cai-day-cheo")
if demo_blog && demo_cat && demo_cat.blog_post_id.blank?
  demo_cat.update!(blog_post: demo_blog)
end

# Logo đối tác (trang chủ): SiteImage bắt buộc có file khi *tạo mới* — phải attach trước save! đầu tiên.
partner_icon = Rails.root.join("public/icon.svg")
if File.exist?(partner_icon)
  6.times do |i|
    si = SiteImage.find_or_initialize_by(category: "partner", position: i)
    si.published = true
    si.alt_text = "Đối tác minh họa #{i + 1}"
    si.link_url = nil
    unless si.file.attached?
      File.open(partner_icon, "rb") do |io|
        si.file.attach(io: io, filename: "partner-#{i + 1}.svg", content_type: "image/svg+xml")
      end
    end
    si.save!
  end
  puts "[seeds] SiteImage đối tác: 6 logo (SVG minh họa từ public/icon.svg — có thể đổi trong quản trị)."
else
  puts "[seeds] Bỏ qua SiteImage đối tác: không thấy #{partner_icon}"
end
