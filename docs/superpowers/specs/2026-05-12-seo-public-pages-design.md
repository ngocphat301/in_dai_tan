# Thiết kế: SEO kỹ thuật cho trang công khai (In Tân Đại)

**Ngày:** 2026-05-12  
**Trạng thái:** Đã duyệt ý tưởng (gói A — đầy đủ meta, canonical, OG/Twitter, JSON-LD).  
**Phạm vi:** Trang HTML công khai có ý nghĩa lập chỉ mục; không đổi hành vi nghiệp vụ cốt lõi.

## Mục tiêu

- Chuẩn hóa **meta description**, **canonical**, **Open Graph / Twitter Card** trên các URL công khai quan trọng.
- Bổ sung **JSON-LD** (`Organization`, `WebSite`, `BlogPosting`/`Article`, `Product`) để máy tìm kiếm và mạng xã hội hiểu rõ thực thể trang.
- Giữ **robots.txt** và **sitemap** hiện có; không thêm `SearchAction` trong giai đoạn 1 (tránh mâu thuẫn với `Disallow: /search`).

## Nguyên tắc kỹ thuật

1. **Không thêm gem** mới cho meta: dùng helper + partial Slim trong layout hiện tại, thống nhất với `content_for :head` đã có.
2. **Host chuẩn:** Một hostname production duy nhất (ví dụ `inantandai.com` — **không** tiền tố `www` trừ khi đổi quyết định triển khai). Giá trị đọc từ biến môi trường (ví dụ `CANONICAL_HOST` hoặc `SITE_HOST`) để URL tuyệt đối trong OG/canonical/JSON-LD khớp khi deploy.
3. **HTTPS:** Mọi URL tuyệt đối trong thẻ SEO dùng `https://`.
4. **Trùng thẻ:** Tránh lặp `meta name="description"` — nếu view cũ đã `content_for :head` với description, gộp vào luồng `@seo` hoặc bỏ duplicate trong view sau khi layout render đủ.

## Hợp đồng dữ liệu `@seo` (ApplicationController / helpers)

Hash (hoặc object đơn giản) gán trong controller hoặc đầu view, đọc trong partial SEO:

| Khóa | Bắt buộc | Ghi chú |
|------|----------|---------|
| `title` | Có | Phần tiêu đề trước suffix thương hiệu trong `<title>` (giữ quy ước layout hiện tại). |
| `description` | Có | Chuỗi mô tả; cắt độ dài thống nhất (ví dụ max 300 ký tự, align với blog). |
| `canonical` | Có | URL tuyệt đối của **bản** đang serve (bao gồm query khi query làm thay đổi nội dung hợp lệ, ví dụ `category` trên catalog). |
| `og_type` | Có | `website` \| `article` \| `product`. |
| `og_image` | Khuyến nghị | URL tuyệt đối; fallback: logo thương hiệu / ảnh mặc định site. |
| `noindex` | Không | Mặc định `false`. Chỉ `true` nơi không muốn index (ví dụ có thể dùng cho trang tìm kiếm nếu cần nhất quán với chính sách). |

**OG/Twitter:** Sinh `og:title`, `og:description`, `og:url`, `og:image`, `og:type`, `og:locale` (`vi_VN`), và `twitter:card` = `summary_large_image` + các thẻ title/description/image tương ứng.

**Canonical:** `<link rel="canonical" href="...">` trùng `og:url` trừ khi có lý do tách (mặc định trùng).

## JSON-LD (giai đoạn 1)

- **`Organization`:** Tên thương hiệu, `url` gốc site, `logo` nếu có URL ổn định; có thể gộp địa chỉ/hotline nếu dữ liệu đã có trong app hoặc ENV (không bịa số liệu).
- **`WebSite`:** `url` gốc, `name`; **không** thêm `potentialAction` kiểu `SearchAction` trong giai đoạn 1 vì `/search` đang `Disallow` trong `robots.txt`.
- **`BlogPosting` / `Article`** (trang chi tiết blog): `headline`, `url`, `datePublished` (và `dateModified` nếu có), `image` nếu có avatar URL tuyệt đối, mô tả ngắn.
- **`Product` + `Offer`** (trang chi tiết sản phẩm): `name`, `image` (gallery ảnh đầu hoặc danh sách), `offers` với `price`, `priceCurrency` = `VND`, `availability` map từ trạng thái thật (mặc định an toàn: `https://schema.org/InStock` hoặc giá trị phù hợp dữ liệu).

Giữ nguyên script JSON-LD **`ItemList`** hiện có cho khối «Quy mô xưởng in».

## Bảng trang → nguồn nội dung SEO

| Controller#action | `title` / `description` | `og_type` | `og_image` |
|-------------------|-------------------------|-----------|------------|
| `home#index` | Copy từ `h1` ẩn / tagline + mô tả ngắn cố định hoặc ENV | `website` | Hero mặc định hoặc banner đầu nếu có |
| `pages#about` | Giữ title; description như meta hiện tại hoặc tinh chỉnh | `website` | Fallback logo |
| `pages#contact` | Tương tự | `website` | Fallback logo |
| `products#index` | Tiêu đề danh mục + mô tả tổng quan; có `category` thì nhấn tên danh mục | `website` | Ảnh đại diện danh mục nếu có, không thì fallback |
| `products#show` | `@product.name` + mô tả từ `description` cắt ngắn | `product` | Ảnh gallery đầu |
| `blog_posts#index` (mọi biến thể hub/dịch vụ/dự án) | `@blog_list_title` + mô tả cố định theo ngữ cảnh danh sách | `website` | Ảnh featured nếu có, không thì fallback |
| `blog_posts#show` | `meta_title` / `title`; `meta_description` / excerpt (đã có) | `article` | Avatar bài nếu có |

| `searches#index` | Tối thiểu; `noindex: true` tùy chọn | `website` | Fallback |

## Tích hợp layout

- File `app/views/layouts/application.html.slim`: sau `= yield :head`, gọi partial một lần (ví dụ `layouts/seo_tags`) với `@seo` đã merge **default** (site name, host, ảnh mặc định).
- Nếu `@seo` thiếu ở trang công khai: coi là lỗi triển khai — trong development có thể log cảnh báo; test integration bắt buộc đủ các route trên.

## Kiểm thử

- Integration test (hoặc mở rộng test hiện có): GET vài URL, assert tồn tại `link[rel="canonical"]`, vài `meta[property^="og:"]`, và ít nhất một block `script[type="application/ld+json"]` chứa `@type` mong đợi cho `home`, `blog_posts#show`, `products#show`.

## Ngoài phạm vi giai đoạn 1

- Đổi chính sách `robots.txt` cho `/search`.
- `hreflang` (site đơn ngững).
- Sitemap bổ sung ảnh / tin tức Google News.
- Tối ưu Core Web Vitals ngoài thẻ meta (đã có lazy load một phần).

## Rủi ro / lưu ý

- **Giá / tồn kho trong `Product`:** Chỉ khai báo schema khớp dữ liệu thật; nếu không chắc `availability`, dùng giá trị trung tính theo tài liệu schema.org.
- **URL ảnh OG:** Active Storage cần host phục vụ file công khai; URL trong OG phải truy cập được từ internet (không localhost).

---

**Self-review:** Không còn placeholder TBD cho quyết định đã chốt. Host chuẩn cụ thể (`www` hay không) do team deploy chọn một và cấu hình ENV — mặc định đề xuất khớp `config.hosts` hiện tại (`inantandai.com`).
