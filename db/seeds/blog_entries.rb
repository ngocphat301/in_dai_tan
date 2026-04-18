# frozen_string_literal: true

# 10 dịch vụ · 10 sản phẩm · 10 tin tức · 3 dự án (slide trang chủ) · 6 quy mô xưởng — avatar trong db/seed_assets/blog/
module BlogEntries
  SEED_BLOG_POSTS = [
    # —— Dịch vụ (10) —— img 01–10
    {
      kind: :service,
      image: "img_01.jpg",
      slug: "in-sach-theo-yeu-cau",
      title: "In sách theo yêu cầu — offset & kỹ thuật số, số lượng linh hoạt",
      excerpt: "Tư vấn khổ sách, loại giấy, gia công đóng gói và báo giá minh bạch cho doanh nghiệp và cá nhân.",
      meta_title: "In sách theo yêu cầu | In Tân Đại",
      meta_description: "In sách số lượng ít đến lớn: bìa cứng, mềm, đóng gáy keo, lò xo. Giao hàng toàn quốc.",
      published_at: Time.zone.parse("2026-01-08 09:00"),
      tag_list: "goi-in-sach",
      body: <<~HTML
        <p>In sách là một trong những dịch vụ cốt lõi giúp lưu trữ tri thức và thương hiệu. Tại xưởng, chúng tôi xử lý trọn gói từ <strong>thiết kế preflight</strong>, in thử mẫu, đến gia công đóng quyển và đóng gói an toàn khi vận chuyển.</p>
        <h2>Lựa chọn phù hợp từng đơn hàng</h2>
        <p>Với đơn <em>số lượng ít</em>, in kỹ thuật số giúp rút ngắn thời gian và giữ màu ổn định. Với <em>số lượng lớn</em>, in offset cho chi phí đơn vị tốt hơn và đồng bộ màu theo chuẩn ISO.</p>
        <ul>
          <li>Giấy: couch, ivory, ford, mỹ thuật có vân — tư vấn định lượng theo độ dày bìa và ruột.</li>
          <li>Gia công: cán màng mờ/bóng, ép nhũ, UV cục bộ, bo góc.</li>
          <li>Đóng: keo gáy, khâu chỉ, lò xo, ghim giữa.</li>
        </ul>
        <h2>Quy trình làm việc</h2>
        <p>Khách gửi file PDF chuẩn in (font nhúng, ảnh ≥300 dpi tại kích thước in). Đội ngũ kiểm tra <strong>vùng an toàn</strong>, chỉnh tông màu nếu cần, rồi chốt bản in và tiến độ giao hàng.</p>
        <blockquote>Cam kết: báo giá rõ ràng, không phát sinh chi phí khi đã chốt hợp đồng (trừ thay đổi thiết kế từ phía khách).</blockquote>
        <p>Liên hệ hotline trên website để nhận mẫu giấy và bảng giá tham khảo theo từng loại sách.</p>
      HTML
    },
    {
      kind: :service,
      image: "img_02.jpg",
      slug: "in-brochure-catalogue-toan-dien",
      title: "In brochure, catalogue và profile nội bộ — đồng bộ nhận diện thương hiệu",
      excerpt: "Thiết kế lưới layout, in offset hai mặt, gấp nếp và cán bề mặt — phục vụ marketing và bán hàng B2B.",
      meta_title: "In brochure và catalogue | In Tân Đại",
      meta_description: "Brochure gấp ba, catalogue sản phẩm, hồ sơ năng lực — in offset, cán màng, gia công sau in.",
      published_at: Time.zone.parse("2026-01-18 10:30"),
      body: <<~HTML
        <p>Brochure và catalogue là “người bán hàng thầm lặng” tại showroom, hội chợ và buổi gặp đối tác. Chúng tôi hỗ trợ <strong>thiết kế khung lưới</strong> (grid) nhất quán, chọn ảnh sản phẩm độ nét cao và typography dễ đọc.</p>
        <h2>Hình thức gấp &amp; khổ in thông dụng</h2>
        <p>Gấp đôi, gấp ba cửa sổ, gấp chữ Z; khổ A4, A5 hoặc tùy chỉnh theo mockup. Có thể kết hợp <em>túi đựng</em> hoặc <em>kep file</em> cho bộ tài liệu dày.</p>
        <table>
          <tr><th>Hạng mục</th><th>Gợi ý</th></tr>
          <tr><td>Giấy</td><td>Couch 150–250gsm (bìa dày hơn ruột)</td></tr>
          <tr><td>Màu</td><td>CMYK 4 màu; spot color khi có Pantone cố định</td></tr>
          <tr><td>Bề mặt</td><td>Cán màng mờ chống trầy; UV cục bộ làm nổi CTA</td></tr>
        </table>
        <h2>Giao hàng &amp; lưu file</h2>
        <p>Sau in, sản phẩm được kiểm tra lẫn màu, cắt thành phẩm và đóng gói theo kiện. File thiết kế gốc được lưu theo chính sách bảo mật của khách (có thể ký NDA).</p>
      HTML
    },
    {
      kind: :service,
      image: "img_03.jpg",
      slug: "in-name-card-visit-doanh-nghiep",
      title: "In name card, visit — bo góc, cán màng, giao nhanh",
      excerpt: "Danh thiếp chuẩn khổ 90×54 mm hoặc tùy chỉnh; giấy ivory, couch, nhựa trong — đồng bộ bộ nhận diện.",
      meta_title: "In name card và visit | In Tân Đại",
      meta_description: "In card visit offset/kỹ thuật số, bo góc, ép nhũ — báo giá theo số lượng.",
      published_at: Time.zone.parse("2026-01-22 09:00"),
      body: <<~HTML
        <p>Name card là điểm chạm đầu tiên với đối tác. Chúng tôi tư vấn <strong>chất liệu</strong> (ivory 300gsm, couch, giấy mỹ thuật) và hoàn thiện <em>cán màng mờ/bóng</em>, bo góc, ép nhũ logo.</p>
        <h2>Số lượng và tiến độ</h2>
        <p>In kỹ thuật số phù hợp từ vài hộp; offset cho đơn lớn với màu ổn định. Có gói lấy nhanh trong ngày tùy tồn giấy.</p>
      HTML
    },
    {
      kind: :service,
      image: "img_04.jpg",
      slug: "in-phong-bi-thu-van-phong",
      title: "In phong bì thư văn phòng — C4, C5, DL, cửa sổ",
      excerpt: "Offset một hoặc hai mặt, dán keo nếp, cửa sổ địa chỉ — đồng bộ letterhead và name card.",
      meta_title: "In phong bì thư C4 C5 | In Tân Đại",
      meta_description: "Phong bì in logo, offset, cửa sổ tùy chọn — gửi hợp đồng và hành chính.",
      published_at: Time.zone.parse("2026-01-25 11:00"),
      body: <<~HTML
        <p>Phong bì thể hiện sự <strong>chuyên nghiệp</strong> của doanh nghiệp. Khổ C4 (đựng A4 gấp đôi), C5, DL phổ biến cho gửi thư và hóa đơn.</p>
        <ul>
          <li>Cửa sổ: tiết kiệm in địa chỉ khi gửi hàng loạt.</li>
          <li>Keo nếp tự dính: tiện đóng tại văn phòng.</li>
        </ul>
      HTML
    },
    {
      kind: :service,
      image: "img_05.jpg",
      slug: "in-to-roi-poster-kho-lon",
      title: "In tờ rơi, poster khổ lớn — couch, PP trong nhà",
      excerpt: "Từ A5 đến A0; in offset hoặc kỹ thuật số khổ rộng cho sự kiện và chiến dịch quảng cáo.",
      meta_title: "In tờ rơi và poster | In Tân Đại",
      meta_description: "Tờ rơi, poster khổ lớn — couch, cán màng, giao theo đợt.",
      published_at: Time.zone.parse("2026-01-28 14:30"),
      body: <<~HTML
        <p>Tờ rơi và poster cần <strong>file độ phân giải cao</strong> và vùng bleed chuẩn. Chúng tôi kiểm tra màu CMYK trước khi chạy bản in chính.</p>
        <h2>Ứng dụng</h2>
        <p>Khai trương, khuyến mãi theo tuần, hội chợ — có thể gấp nếp hoặc cán màng một mặt nếu treo nơi ẩm.</p>
      HTML
    },
    {
      kind: :service,
      image: "img_06.jpg",
      slug: "in-lich-tuong-ke-van-phong",
      title: "In lịch tường, lịch để bàn — theo bộ nhận diện",
      excerpt: "Lịch 7 tờ, 13 tờ; đóng lò xo, ép keo; in offset màu đều cho quà tặng cuối năm.",
      meta_title: "In lịch tường và để bàn | In Tân Đại",
      meta_description: "Lịch in offset, bế xén, đóng gáy — quà tặng doanh nghiệp.",
      published_at: Time.zone.parse("2026-02-02 08:45"),
      body: <<~HTML
        <p>Lịch là ấn phẩm <strong>theo mùa</strong>, cần chốt sớm để kịp proof và giao trước Tết. Hỗ trợ thiết kế lịch theo template hoặc file khách cung cấp.</p>
        <blockquote>Nên đặt trước ít nhất 8–10 tuần trước dịp lễ để tránh tắc lịch xưởng.</blockquote>
      HTML
    },
    {
      kind: :service,
      image: "img_07.jpg",
      slug: "gia-cong-be-boi-dut-nhu",
      title: "Gia công bế, bồi, dứt nhũ — sau in offset",
      excerpt: "Bế hình đặc thù, bồi cứng, ép nhũ vàng/bạc — hoàn thiện bao bì và nhãn cao cấp.",
      meta_title: "Gia công bế bồi ép nhũ | In Tân Đại",
      meta_description: "Bế nét, bồi sóng, ép nhũ UV — gia công sau in.",
      published_at: Time.zone.parse("2026-02-05 10:15"),
      body: <<~HTML
        <p>Gia công quyết định độ hoàn thiện của thành phẩm. Khuôn bế được bảo quản theo đơn hàng để tái in các đợt sau.</p>
        <h2>Ép nhũ &amp; UV</h2>
        <p>Ép nhũ logo tạo điểm nhấn sang trọng; UV cục bộ làm nổi chi tiết trên nền mờ.</p>
      HTML
    },
    {
      kind: :service,
      image: "img_08.jpg",
      slug: "in-sticker-nhan-decal-cuon",
      title: "In sticker, nhãn decal cuộn — bế theo khuôn",
      excerpt: "Decal giấy, nhựa, trong; in flexo/offset cuộn — phù hợp đóng gói tự động.",
      meta_title: "In sticker và decal cuộn | In Tân Đại",
      meta_description: "Nhãn decal cuộn, bế đúng khuôn, test keo trên mẫu thật.",
      published_at: Time.zone.parse("2026-02-08 13:00"),
      body: <<~HTML
        <p>Nhãn cuộn cần khớp <strong>bước in và khe cắt</strong> trên máy dán. Chúng tôi kiểm tra độ dính trên bề mặt thực tế (chai, hộp) trước khi chạy hàng loạt.</p>
      HTML
    },
    {
      kind: :service,
      image: "img_09.jpg",
      slug: "dong-gap-ho-so-du-thau",
      title: "Đóng gáp hồ sơ dự thầu, catalogue dày",
      excerpt: "Đóng keo gáy, lò xo, ghim giữa — tài liệu dự thầu và báo cáo nhiều trang.",
      meta_title: "Đóng gáy hồ sơ dự thầu | In Tân Đại",
      meta_description: "Đóng catalogue, hồ sơ năng lực — keo, lò xo, bọc bìa cứng.",
      published_at: Time.zone.parse("2026-02-11 09:20"),
      body: <<~HTML
        <p>Hồ sơ dự thầu thường dày và cần <strong>mở phẳng</strong> khi photocopy. Lò xo hoặc keo gáy tùy số trang và yêu cầu bên mời thầu.</p>
        <p>Có thể bọc bìa cứng in offset riêng ruột in kỹ thuật số để tối ưu chi phí.</p>
      HTML
    },
    {
      kind: :service,
      image: "img_10.jpg",
      slug: "tu-van-bao-gia-in-nhanh-24h",
      title: "Tư vấn báo giá in nhanh — phản hồi trong 24h làm việc",
      excerpt: "Gửi mô tả khổ, số lượng, loại giấy — nhận báo giá tham khảo và khuyến nghị công nghệ in.",
      meta_title: "Báo giá in nhanh | In Tân Đại",
      meta_description: "Tư vấn khối lượng in, chọn offset hay kỹ thuật số — báo giá minh bạch.",
      published_at: Time.zone.parse("2026-02-14 16:00"),
      body: <<~HTML
        <p>Đội ngũ kinh doanh hỗ trợ <strong>làm rõ thông số</strong> trước khi báo giá: khổ in, số mặt màu, gia công sau in và địa điểm giao hàng.</p>
        <p>Với file sẵn sàng, thời gian báo giá ngắn hơn; file cần chỉnh sẽ được báo thêm phí preflight nếu có.</p>
      HTML
    },
    # —— Sản phẩm (10) —— img 11–20
    {
      kind: :product,
      image: "img_11.jpg",
      slug: "hop-giay-qua-tang-in-offset-uv",
      title: "Hộp giấy quà tặng in offset — UV cục bộ, cán màng sang trọng",
      excerpt: "Hộp cứng âm dương, bề mặt phẳng phù hợp thương hiệu mỹ phẩm và đồ uống cao cấp.",
      meta_title: "Hộp giấy quà tặng in offset | In Tân Đại",
      meta_description: "Hộp giấy offset, phủ UV, cán màng — bền màu, đóng gói quà tặng doanh nghiệp.",
      published_at: Time.zone.parse("2026-02-01 08:00"),
      tag_list: "goi-in-sach",
      body: <<~HTML
        <p>Hộp quà tặng không chỉ bảo vệ sản phẩm mà còn thể hiện đẳng cấp thương hiệu. Dòng hộp <strong>in offset</strong> cho màu đều, nét chữ sắc, dễ kết hợp <em>UV định vị</em> hoặc <em>ép nhũ logo</em>.</p>
        <h2>Cấu trúc &amp; vật liệu</h2>
        <p>Thường dùng giấy ivory hoặc duplex dán sóng để tăng độ cứng. Nắp âm dương giúp đóng mở êm, có thể thêm nam châm ẩn.</p>
        <ul>
          <li>Kích thước: theo sản phẩm đựng (chai, hộp phụ kiện).</li>
          <li>In: CMYK + spot khi cần màu thương hiệu chuẩn.</li>
        </ul>
        <p>Liên hệ để nhận mẫu cấu trúc và bảng giá theo số lượng.</p>
      HTML
    },
    {
      kind: :product,
      image: "img_12.jpg",
      slug: "hop-pizza-song-e-in-2-mau",
      title: "Hộp pizza sóng E — in 2 mặt, chịu nhiệt &amp; dầu nhẹ",
      excerpt: "Giải pháp bao bì cho chuỗi nhà hàng: sóng E, in flexo/offset tùy số lượng.",
      meta_title: "Hộp pizza sóng E | In Tân Đại",
      meta_description: "Hộp pizza giấy sóng, in logo nắp, giao nhanh số lượng lớn.",
      published_at: Time.zone.parse("2026-02-03 11:00"),
      tag_list: "goi-in-sach",
      body: <<~HTML
        <p>Hộp pizza cần <strong>độ cứng vừa phải</strong> và khả năng thoát hơi nước nhẹ từ đế bánh. Sóng E là lựa chọn phổ biến, cân bằng giữa trọng lượng và giá thành.</p>
        <h2>In ấn &amp; thực phẩm</h2>
        <p>Mực và lớp phủ phù hợp tiếp xúc thực phẩm (theo yêu cầu đơn hàng). Logo in nổi trên nắp giúp nhận diện từ xa.</p>
        <blockquote>Đặt hàng sớm trước mùa cao điểm để xưởng sắp lịch in và gia công ổn định.</blockquote>
      HTML
    },
    {
      kind: :product,
      image: "img_13.jpg",
      slug: "tui-giay-kraft-quai-xach",
      title: "Túi giấy Kraft quai xách — thân thiện môi trường, in 1–4 màu",
      excerpt: "Túi đáy vuông, quai dây cotton hoặc giấy xoắn; phù hợp bán lẻ và sự kiện.",
      meta_title: "Túi giấy Kraft in logo | In Tân Đại",
      meta_description: "Túi giấy Kraft, quai xách, in thương hiệu — tái chế, bền chắc.",
      published_at: Time.zone.parse("2026-02-05 14:00"),
      tag_list: "goi-in-sach",
      body: <<~HTML
        <p>Túi giấy Kraft được ưa chuộng nhờ <strong>vẻ tự nhiên</strong> và khả năng tái chế. Có thể in water-based, hạn chế mùi và thân thiện cửa hàng xanh.</p>
        <h2>Gia công quai &amp; đáy</h2>
        <p>Đục lỗ luồn dây, đáy vuông giúp đứng vững khi đựng chai hoặc hộp quà nhỏ.</p>
      HTML
    },
    {
      kind: :product,
      image: "img_14.jpg",
      slug: "phong-bi-c5-in-logo-nhan-dien",
      title: "Phong bì C5 in logo — đồng bộ văn phòng &amp; gửi thư hành chính",
      excerpt: "Khổ C5 đựng A5; offset 1–2 mặt, cửa sổ tùy chọn.",
      meta_title: "Phong bì C5 in logo | In Tân Đại",
      meta_description: "Phong bì C5, in offset, dán keo nếp — chuẩn văn phòng.",
      published_at: Time.zone.parse("2026-02-07 09:15"),
      tag_list: "goi-in-sach",
      body: <<~HTML
        <p>Phong bì C5 phù hợp tài liệu gấp A4 làm đôi hoặc tờ rơi A5. Logo và thông tin liên hệ được in <strong>đồng bộ</strong> với letterhead.</p>
        <ul>
          <li>Cửa sổ: tiết kiệm in địa chỉ khi gửi hàng loạt.</li>
          <li>Keo nếp: tiện đóng gói tại văn phòng.</li>
        </ul>
      HTML
    },
    {
      kind: :product,
      image: "img_15.jpg",
      slug: "tem-nhan-decal-giay-boc-mang",
      title: "Tem nhãn decal giấy — cán màng, dán chai lọ &amp; hộp giấy",
      excerpt: "In flexo/offset cuộn; keo phù hợp giấy, thủy tinh và nhựa (theo test dính).",
      meta_title: "Tem nhãn decal giấy | In Tân Đại",
      meta_description: "Decal giấy, cán màng, bế đúng khuôn — tem sản phẩm và barcode.",
      published_at: Time.zone.parse("2026-02-10 13:40"),
      body: <<~HTML
        <p>Tem nhãn ảnh hưởng trực tiếp đến <strong>nhận diện</strong> và quét mã vạch. Chúng tôi bế theo khuôn chuẩn, kiểm tra độ dính trên mẫu thật trước khi chạy hàng loạt.</p>
        <h2>Ứng dụng</h2>
        <p>Mỹ phẩm, thực phẩm đóng gói, hàng tiêu dùng — lưu ý bảo quản tránh ẩm cho decal giấy.</p>
      HTML
    },
    {
      kind: :product,
      image: "img_16.jpg",
      slug: "hop-am-duong-my-pham",
      title: "Hộp âm dương mỹ phẩm — khay nhựa PET &amp; lót nhung",
      excerpt: "Hộp cứng bọc giấy in, khay nội tùy chỉnh — phù hợp set quà Tết và combo bán lẻ.",
      meta_title: "Hộp âm dương mỹ phẩm | In Tân Đại",
      meta_description: "Hộp âm dương, khay nhựa, lót nhung — bao bì mỹ phẩm cao cấp.",
      published_at: Time.zone.parse("2026-02-12 10:00"),
      body: <<~HTML
        <p>Hộp âm dương mang lại cảm giác <strong>mở hộp cao cấp</strong>. Khay nhựa định hình chai/lọ, lót nhung chống trầy.</p>
        <h2>Tùy biến</h2>
        <p>Màu sắc bìa, họa tiết UV/hot stamping theo campaign. Có thể thêm ribbon hoặc seal dán.</p>
      HTML
    },
    {
      kind: :product,
      image: "img_17.jpg",
      slug: "thung-carton-3-lop-in-flexo",
      title: "Thùng carton 3 lớp in flexo — vận chuyển &amp; kho bãi",
      excerpt: "Sóng B/C, in flexo 1–3 màu trên mặt ngoài; đóng ghim hoặc dán.",
      meta_title: "Thùng carton 3 lớp in flexo | In Tân Đại",
      meta_description: "Thùng carton sóng, in flexo logo — đóng gói hàng xuất kho.",
      published_at: Time.zone.parse("2026-02-14 08:30"),
      body: <<~HTML
        <p>Thùng carton <strong>3 lớp</strong> đủ dùng cho nhiều lô hàng trung bình. Flexo phù hợp số lượng lớn, chi phí đơn vị thấp.</p>
        <p>Kiểm tra độ chịu nén theo mẫu (ISTA đơn giản) trước khi chốt quy cách sóng.</p>
      HTML
    },
    {
      kind: :product,
      image: "img_18.jpg",
      slug: "to-roi-a5-in-nhanh",
      title: "Tờ rơi A5 in nhanh — couch 150gsm, gấp đôi tùy chọn",
      excerpt: "Phát sóng cửa hàng, khuyến mãi theo tuần — giao trong 24–48h tùy tồn kho giấy.",
      meta_title: "Tờ rơi A5 in nhanh | In Tân Đại",
      meta_description: "Tờ rơi A5 couch, in kỹ thuật số/offset — khuyến mãi, sự kiện.",
      published_at: Time.zone.parse("2026-02-16 15:00"),
      body: <<~HTML
        <p>Tờ rơi A5 dễ phát tay và để lẫn trong hóa đơn. Chất liệu couch <strong>150gsm</strong> cân bằng giữa độ cứng và chi phí.</p>
        <ul>
          <li>In nhanh: phù hợp đổi nội dung theo đợt khuyến mãi.</li>
          <li>Cán màng một mặt nếu treo nơi ẩm.</li>
        </ul>
      HTML
    },
    {
      kind: :product,
      image: "img_19.jpg",
      slug: "hop-giay-dung-banh-trung-thu",
      title: "Hộp giấy đựng bánh Trung thu — khay nhựa 4–6 ngăn",
      excerpt: "Thiết kế theo khuôn bánh; in offset màu sắc lễ hội, cán màng bảo vệ bề mặt.",
      meta_title: "Hộp bánh Trung thu | In Tân Đại",
      meta_description: "Hộp giấy bánh trung thu, khay nhựa, in offset — quà tặng mùa lễ.",
      published_at: Time.zone.parse("2026-02-20 09:00"),
      body: <<~HTML
        <p>Hộp bánh Trung thu cần <strong>chắc chắn</strong> và bắt mắt trên kệ. Khay nhựa giữ cố định từng chiếc, giảm va đập khi vận chuyển.</p>
        <h2>Mùa vụ</h2>
        <p>Nên đặt trước ít nhất 6–8 tuần để kịp proof màu và sản xuất hàng loạt.</p>
      HTML
    },
    {
      kind: :product,
      image: "img_20.jpg",
      slug: "name-card-nhua-trong-pp",
      title: "Name card nhựa trong PP — bền nước, bo góc",
      excerpt: "Danh thiếp đặc biệt cho F&amp;B và spa; in UV hoặc trắng mực trên nền trong.",
      meta_title: "Name card nhựa PP | In Tân Đại",
      meta_description: "Card visit nhựa trong, bo góc — bền, dễ lau.",
      published_at: Time.zone.parse("2026-02-22 11:20"),
      body: <<~HTML
        <p>Thẻ nhựa trong tạo ấn tượng <strong>hiện đại</strong>, chống thấm nước tốt hơn giấy thường. Phù hợp môi trường ẩm hoặc ngoài trời ngắn hạn.</p>
        <p>Thiết kế nên tránh font quá nhỏ trên nền trong; có thể dùng nền mờ nhẹ để tăng độ tương phản.</p>
      HTML
    },
    # —— Tin tức (10) —— img 21–24 + 01–06 (tái sử dụng file seed)
    {
      kind: :news,
      image: "img_21.jpg",
      slug: "tin-xu-huong-bao-bi-ben-vung-2026",
      title: "Xu hướng bao bì bền vững 2026: giảm nhựa một lần, tăng giấy tái chế",
      excerpt: "Doanh nghiệp F&amp;C và bán lẻ đang chuyển dần sang giấy có chứng nhận FSC và mực gốc nước.",
      meta_title: "Xu hướng bao bì bền vững 2026 | Tin tức In Tân Đại",
      meta_description: "Phân tích xu hướng bao bì giấy, tái chế và yêu cầu từ người tiêu dùng.",
      published_at: Time.zone.parse("2026-03-01 08:00"),
      body: <<~HTML
        <p>Thị trường trong nước ghi nhận nhu cầu <strong>bao bì có thể tái chế</strong> tăng rõ trong mảng đồ uống và thực phẩm đóng gói. Giấy Kraft và sóng thuần giấy được ưu tiên hơn hộp nhựa dùng một lần.</p>
        <h2>Tác động tới chuỗi cung ứng</h2>
        <p>Nhà sản xuất cần dự trù thời gian proof vật liệu mới và kiểm tra độ ẩm bảo quản sản phẩm — đặc biệt với thực phẩm tươi sống.</p>
        <ul>
          <li>Chứng nhận nguồn gốc giấy (FSC/PEFC) hỗ trợ thông điệp thương hiệu xanh.</li>
          <li>Mực gốc nước và dung môi ít VOC giảm mùi khi đóng gói thực phẩm.</li>
        </ul>
        <p>Chúng tôi sẽ tiếp tục cập nhật case study triển khai thực tế tại kho khách hàng.</p>
      HTML
    },
    {
      kind: :news,
      image: "img_22.jpg",
      slug: "nganh-in-viet-nam-thach-thuc-gia-thanh",
      title: "Ngành in Việt Nam: thách thức giá nguyên liệu và tối ưu tồn kho",
      excerpt: "Biến động giá giấy nhập khẩu khiến nhiều xưởng cân nhắc hợp đồng dài hạn và dự trữ sóng.",
      meta_title: "Thách thức ngành in Việt Nam | Tin tức",
      meta_description: "Giá giấy, tối ưu tồn kho và linh hoạt đơn hàng trong ngành in.",
      published_at: Time.zone.parse("2026-03-03 09:30"),
      body: <<~HTML
        <p>Năm 2026, <strong>chi phí đầu vào</strong> vẫn là yếu tố nhạy cảm. Các xưởng nhỏ và vừa chuyển sang mô hình đặt giấy theo tuần, giảm tồn kho chiếm vốn.</p>
        <h2>Gợi ý cho đối tác đặt in</h2>
        <p>Gom đơn theo đợt, chốt khổ giấy chung giúp tối ưu khai thác khổ máy và giảm dư thừa.</p>
        <blockquote>Minh bạch báo giá theo từng đợt giấy giúp hai bên cùng chia sẻ rủi ro nguyên liệu.</blockquote>
      HTML
    },
    {
      kind: :news,
      image: "img_23.jpg",
      slug: "so-sanh-in-offset-va-in-ky-thuat-so",
      title: "So sánh in offset và in kỹ thuật số: khi nào nên chọn cái nào?",
      excerpt: "Offset phù hợp số lớn và đồng bộ màu; kỹ thuật số linh hoạt bản in thử và số lượng ít.",
      meta_title: "Offset vs kỹ thuật số | Tin tức In Tân Đại",
      meta_description: "Hướng dẫn chọn công nghệ in offset hoặc kỹ thuật số theo số lượng và tiến độ.",
      published_at: Time.zone.parse("2026-03-05 10:00"),
      body: <<~HTML
        <p><strong>In offset</strong> khắc bản, chi phí khuôn ban đầu cao hơn nhưng đơn vị giảm mạnh khi tăng số lượng. <strong>In kỹ thuật số</strong> không cần khuôn, phù hợp cá nhân hóa và in mẫu.</p>
        <table>
          <tr><th>Tiêu chí</th><th>Offset</th><th>Kỹ thuật số</th></tr>
          <tr><td>Số lượng</td><td>Từ vài nghìn bản</td><td>Từ 1 bản</td></tr>
          <tr><td>Màu đặc</td><td>Spot/Pantone ổn định</td><td>Phụ thuộc máy 4–6 màu</td></tr>
          <tr><td>Thời gian</td><td>Dài hơn (lên bản)</td><td>Nhanh hơn</td></tr>
        </table>
        <p>Đội ngũ tư vấn của chúng tôi có thể đề xuất phương án lai: in số cho mẫu, offset cho lô chính.</p>
      HTML
    },
    {
      kind: :news,
      image: "img_24.jpg",
      slug: "chuan-hoa-file-in-pdf-nhu-the-nao",
      title: "Chuẩn hóa file in PDF: font, ảnh và vùng bleed an toàn",
      excerpt: "File sai font nhúng hoặc độ phân giải ảnh thấp là nguyên nhân hay gặp khiến lệch màu hoặc mờ.",
      meta_title: "Chuẩn file PDF cho in ấn | Tin tức",
      meta_description: "Hướng dẫn chuẩn bị file PDF in offset và kỹ thuật số: bleed, font, ảnh.",
      published_at: Time.zone.parse("2026-03-07 14:00"),
      body: <<~HTML
        <p>Trước khi in, file nên ở dạng <strong>PDF/X</strong> hoặc PDF nhúng font đầy đủ. Ảnh raster nên đạt tối thiểu 300 dpi tại kích thước in thật.</p>
        <h2>Bleed và vùng an toàn</h2>
        <p>Bleed thường 3 mm mỗi bên để cắt không lộ viền trắng. Vùng an toàn giữ chữ và logo cách mép cắt đủ xa.</p>
        <ul>
          <li>Chế độ màu: CMYK cho in thương mại.</li>
          <li>Đen giàu: nên dùng rich black theo profile xưởng.</li>
        </ul>
      HTML
    },
    {
      kind: :news,
      image: "img_01.jpg",
      slug: "bao-bi-thuc-pham-quy-dinh-ghi-nhan",
      title: "Bao bì thực phẩm: những thông tin bắt buộc khi in nhãn mác",
      excerpt: "Tên sản phẩm, nơi sản xuất, hạn sử dụng và thành phần — tránh rủi ro pháp lý khi in nhãn.",
      meta_title: "Quy định nhãn bao bì thực phẩm | Tin tức",
      meta_description: "Thông tin phải có trên nhãn bao bì thực phẩm khi in ấn.",
      published_at: Time.zone.parse("2026-03-09 08:45"),
      body: <<~HTML
        <p>Nhãn thực phẩm cần tuân thủ quy định hiện hành về <strong>an toàn thông tin người tiêu dùng</strong>. Doanh nghiệp nên phối hợp bộ phận pháp chế khi thiết kế.</p>
        <p>Chúng tôi hỗ trợ kiểm tra kỹ thuật in (độ đậm mã vạch, kích thước chữ) nhưng không thay thế tư vấn pháp lý chính thức.</p>
      HTML
    },
    {
      kind: :news,
      image: "img_02.jpg",
      slug: "ung-dung-can-mang-bong-va-mo",
      title: "Ứng dụng cán màng bóng và mờ: độ bền bề mặt và cảm nhận thương hiệu",
      excerpt: "Màng mờ giảm chói; màng bóng làm rực màu — lựa chọn theo ngành hàng và điều kiện bảo quản.",
      meta_title: "Cán màng bóng và mờ | Tin tức In Tân Đại",
      meta_description: "So sánh cán màng bóng, mờ trên bao bì giấy và ảnh hưởng độ bền.",
      published_at: Time.zone.parse("2026-03-11 11:30"),
      body: <<~HTML
        <p><strong>Cán màng</strong> tạo lớp bảo vệ chống trầy xước và thấm nước nhẹ. Màng mờ cho cảm giác sang trọng; màng bóng làm màu “nổi” hơn dưới ánh đèn.</p>
        <h2>Lưu ý tái chế</h2>
        <p>Một số loại màng khó tách khỏi giấy khi tái chế — cần cân nhắc theo chiến lược ESG của thương hiệu.</p>
      HTML
    },
    {
      kind: :news,
      image: "img_03.jpg",
      slug: "toi-uu-kich-thuoc-thung-carton-giam-chi-phi",
      title: "Tối ưu kích thước thùng carton để giảm chi phí vận chuyển",
      excerpt: "Thùng quá lớn làm lãng phí sóng giấy và phí ship; quá nhỏ gây hư hàng — cách tính nhanh.",
      meta_title: "Tối ưu thùng carton | Tin tức",
      meta_description: "Cách chọn kích thước thùng carton phù hợp sản phẩm và logistics.",
      published_at: Time.zone.parse("2026-03-14 09:00"),
      body: <<~HTML
        <p>Quy cách thùng nên bám sát <strong>kích thước sản phẩm + đệm chống sốc</strong>. Dư không gian khiến hàng dịch chuyển trong quá trình vận chuyển.</p>
        <ul>
          <li>Đo mẫu thật trước khi chạy số lượng lớn.</li>
          <li>Xếp pallet chuẩn giúp giảm hư hỏng cạnh thùng.</li>
        </ul>
      HTML
    },
    {
      kind: :news,
      image: "img_04.jpg",
      slug: "mau-sac-thuong-hieu-in-va-so-pantone",
      title: "Màu sắc thương hiệu khi in ấn: Pantone, CMYK và độ lệch proof",
      excerpt: "Chuyển đổi Pantone sang CMYK luôn có sai số — cần proof in trên giấy thật trước khi chạy lô.",
      meta_title: "Màu Pantone & CMYK | Tin tức",
      meta_description: "Quản lý màu thương hiệu khi in offset và proof màu.",
      published_at: Time.zone.parse("2026-03-16 13:15"),
      body: <<~HTML
        <p>Mỗi loại giấy hút mực khác nhau ảnh hưởng đến <strong>độ sáng màu</strong>. Proof trên giấy mục tiêu là bước không nên bỏ qua với đơn hàng lớn.</p>
        <blockquote>Khi cần khớp màu tuyệt đối, cân nhắc in spot hoặc phủ lớp đặc biệt.</blockquote>
        <p>Đội ngũ QC của chúng tôi đối chiếu bảng màu chuẩn theo hợp đồng từng đợt sản xuất.</p>
      HTML
    },
    {
      kind: :news,
      image: "img_05.jpg",
      slug: "bao-mat-file-thiet-ke-khi-lam-viec-voi-xuong-in",
      title: "Bảo mật file thiết kế khi làm việc với xưởng in",
      excerpt: "NDA, phân quyền file và watermark mẫu — giảm rủi ro lộ bản thiết kế trước khi phát hành.",
      meta_title: "Bảo mật file thiết kế | Tin tức",
      meta_description: "Thực hành bảo mật file khi gửi xưởng in và in mẫu.",
      published_at: Time.zone.parse("2026-03-18 10:45"),
      body: <<~HTML
        <p>Doanh nghiệp nên ký <strong>thỏa thuận bảo mật</strong> khi gửi file gốc. Xưởng in chỉ lưu file theo thời hạn phục vụ bảo hành in ấn trừ khi có thỏa thuận khác.</p>
        <p>Mẫu in có thể đóng dấu chìm hoặc watermark để hạn chế sao chép khi trưng bày.</p>
      HTML
    },
    {
      kind: :news,
      image: "img_06.jpg",
      slug: "trien-lam-bao-bi-ha-noi-2026-diem-hen-nganh",
      title: "Triển lãm bao bì &amp; in ấn: điểm hẹn công nghệ và vật liệu mới 2026",
      excerpt: "Cập nhật máy in, dòng mực và giấy tái chế ra mắt tại các gian hàng trong khu vực.",
      meta_title: "Triển lãm bao bì 2026 | Tin tức In Tân Đại",
      meta_description: "Tin triển lãm ngành bao bì, vật liệu và máy in tại Việt Nam.",
      published_at: Time.zone.parse("2026-03-20 15:30"),
      body: <<~HTML
        <p>Các triển lãm ngành cho phép <strong>so sánh trực tiếp</strong> mẫu in, máy bế và dây chuyền hoàn thiện. Đây là dịp tốt để tìm nhà cung cấp mực, keo và giấy mới.</p>
        <h2>Gợi ý khi tham quan</h2>
        <p>Mang theo mẫu sản phẩm thật để hỏi tư vấn kích thước bao bì và vật liệu thay thế nhựa.</p>
        <p>Chúng tôi sẽ cập nhật ghi chú từ sàn triển lãm trên blog trong các bài tiếp theo.</p>
      HTML
    },
    # —— Dự án (3) —— carousel «Dự án nổi bật»: mỗi slide hiển thị đủ 3 ảnh
    {
      kind: :project,
      image: "img_14.jpg",
      slug: "du-an-bao-bi-my-pham-cao-cap",
      title: "Dự án bao bì mỹ phẩm cao cấp — in offset, cán màng mờ",
      excerpt: "Bộ hộp cứng, tờ hướng dẫn và sleeve giấy đồng bộ nhận diện; kiểm soát màu theo proof trên giấy thật.",
      meta_title: "Dự án bao bì mỹ phẩm | In Tân Đại",
      meta_description: "Case study in offset, cán màng và hoàn thiện bao bì mỹ phẩm.",
      published_at: Time.zone.parse("2026-02-01 09:00"),
      body: <<~HTML
        <p>Dự án yêu cầu <strong>độ chính xác màu</strong> cao và bề mặt mờ sang trọng. Chúng tôi in offset, cán màng mờ và bế nắp hít chặt.</p>
        <h2>Thách thức &amp; giải pháp</h2>
        <p>Proof trên giấy đích trước khi chạy lô; QC đối chiếu Pantone theo hợp đồng từng đợt.</p>
      HTML
    },
    {
      kind: :project,
      image: "img_15.jpg",
      slug: "du-an-an-pham-su-kien-doanh-nghiep",
      title: "Bộ ấn phẩm sự kiện doanh nghiệp — brochure, standee, túi giấy",
      excerpt: "Giao trong 10 ngày: brochure gấp ba, standee và túi giấy in logo — đồng bộ font và màu thương hiệu.",
      meta_title: "Ấn phẩm sự kiện doanh nghiệp | In Tân Đại",
      meta_description: "In brochure, standee, túi giấy cho sự kiện — case study.",
      published_at: Time.zone.parse("2026-02-05 10:30"),
      body: <<~HTML
        <p>Bộ tài liệu sự kiện cần <strong>đồng bộ</strong> giữa các hạng mục. Chúng tôi chốt một profile màu CMYK dùng chung cho toàn bộ ấn phẩm.</p>
        <p>Gia công: cán màng, bế nếp gấp chuẩn, dán túi giấy có đáy cứng.</p>
      HTML
    },
    {
      kind: :project,
      image: "img_16.jpg",
      slug: "du-an-hop-qua-tet-in-offset",
      title: "Hộp quà Tết in offset — khay nhựa, nắp nam châm",
      excerpt: "Hộp cứng khổ tùy chỉnh, in màu lễ hội, khay nhựa định hình sản phẩm — tối ưu chi phí theo số lượng.",
      meta_title: "Hộp quà Tết in offset | In Tân Đại",
      meta_description: "Dự án hộp quà Tết, in offset và khay nhựa.",
      published_at: Time.zone.parse("2026-02-12 08:00"),
      body: <<~HTML
        <p>Mùa cao điểm cần <strong>tiến độ rõ ràng</strong>. Chúng tôi phối hợp in offset, bế và lắp ráp khay tại xưởng.</p>
        <blockquote>Cam kết proof màu trước khi chạy lô chính.</blockquote>
      HTML
    },
    # —— Quy mô xưởng in (6) —— lưới 1 ảnh lớn + 5 ảnh nhỏ trên trang chủ
    {
      kind: :factory_scale,
      image: "img_07.jpg",
      slug: "may-in-offset-quy-mo-xuong",
      title: "Máy in offset",
      excerpt: "In màu chuẩn, độ sắc nét cao, tái hiện màu ổn định cho số lượng lớn — phù hợp hộp giấy, bao bì cao cấp và ấn phẩm thương mại.",
      meta_title: "Máy in offset | Quy mô xưởng In Tân Đại",
      meta_description: "Hệ thống in offset phục vụ bao bì và ấn phẩm số lượng lớn.",
      published_at: Time.zone.parse("2026-01-05 09:00"),
      body: <<~HTML
        <p>Dây chuyền <strong>in offset</strong> giúp đơn vị giá tốt khi tăng số lượng, đồng thời giữ đồng đều màu giữa các ca in.</p>
        <p>Phù hợp catalogue, hộp cứng, tờ rơi và bao bì cần độ bóng màu cao.</p>
      HTML
    },
    {
      kind: :factory_scale,
      image: "img_08.jpg",
      slug: "may-can-mang-tu-dong-quy-mo-xuong",
      title: "Máy cán màng tự động",
      excerpt: "Tăng độ bền, chống trầy xước và tạo hiệu ứng bề mặt bóng hoặc mờ theo định hướng thương hiệu.",
      meta_title: "Máy cán màng tự động | Quy mô xưởng In Tân Đại",
      meta_description: "Cán màng bóng/mờ tự động cho ấn phẩm và bao bì.",
      published_at: Time.zone.parse("2026-01-06 09:00"),
      body: <<~HTML
        <p>Lớp màng bảo vệ <strong>bề mặt in</strong>, giảm trầy xước trong vận chuyển và trưng bày.</p>
        <ul>
          <li>Màng bóng: màu rực, phù hợp bao bì cần “bắt mắt”.</li>
          <li>Màng mờ: cảm giác cao cấp, giảm chói dưới ánh đèn.</li>
        </ul>
      HTML
    },
    {
      kind: :factory_scale,
      image: "img_09.jpg",
      slug: "may-boi-song-quy-mo-xuong",
      title: "Máy bồi sóng",
      excerpt: "Ghép lớp giấy với sóng để tăng độ cứng và khả năng chịu tải — phục vụ thùng carton, hộp sóng.",
      meta_title: "Máy bồi sóng | Quy mô xưởng In Tân Đại",
      meta_description: "Bồi sóng tăng cứng cho thùng và hộp carton.",
      published_at: Time.zone.parse("2026-01-07 09:00"),
      body: <<~HTML
        <p>Quy trình <strong>bồi sóng</strong> tạo cấu trúc 3 lớp hoặc 5 lớp tùy tải trọng yêu cầu.</p>
        <p>Phù hợp thùng ship thương mại điện tử và bao bì cần chống va đập.</p>
      HTML
    },
    {
      kind: :factory_scale,
      image: "img_10.jpg",
      slug: "may-be-quy-mo-xuong",
      title: "Máy bế",
      excerpt: "Cắt, bế thành phẩm theo khuôn chuẩn — đa dạng kiểu dáng hộp, mép sắc nét và đồng nhất lô in.",
      meta_title: "Máy bế | Quy mô xưởng In Tân Đại",
      meta_description: "Bế dạng hộp và chi tiết bao bì theo khuôn.",
      published_at: Time.zone.parse("2026-01-08 09:00"),
      body: <<~HTML
        <p>Máy bế hiện đại xử lý <strong>form hộp phức tạp</strong> với độ lệch thấp giữa các tờ.</p>
        <p>Kết hợp file thiết kế chuẩn bleed giúp mép cắt sạch, không lộ viền trắng.</p>
      HTML
    },
    {
      kind: :factory_scale,
      image: "img_17.jpg",
      slug: "phong-qc-mau-quy-mo-xuong",
      title: "Phòng QC màu &amp; proof",
      excerpt: "Đối chiếu proof trên giấy đích, kiểm soát tông màu giữa các ca in và giữ nhất quán lô hàng.",
      meta_title: "QC màu &amp; proof | Quy mô xưởng In Tân Đại",
      meta_description: "Kiểm soát màu in offset và kỹ thuật số theo chuẩn hợp đồng.",
      published_at: Time.zone.parse("2026-01-09 09:00"),
      body: <<~HTML
        <p>Phòng QC tập trung vào <strong>độ lệch màu</strong> giữa proof đã ký và thành phẩm thực tế, đặc biệt với bao bì cần đồng bộ nhiều hạng mục.</p>
        <p>Lưu mẫu seal theo từng đơn để tái in các đợt sau khớp tông màu.</p>
      HTML
    },
    {
      kind: :factory_scale,
      image: "img_18.jpg",
      slug: "kho-giay-nguyen-lieu-quy-mo-xuong",
      title: "Kho giấy nguyên liệu",
      excerpt: "Tồn kho couch, ivory, sóng và giấy mỹ thuật — rút ngắn lead time khi khách cần gấp.",
      meta_title: "Kho giấy nguyên liệu | Quy mô xưởng In Tân Đại",
      meta_description: "Nguồn giấy ổn định cho in offset và gia công bao bì.",
      published_at: Time.zone.parse("2026-01-10 09:00"),
      body: <<~HTML
        <p>Kho được tổ chức theo <strong>định lượng và khổ</strong> để xuất liệu nhanh cho lệnh in, giảm thời gian chờ nhập thêm từ nhà cung cấp.</p>
        <p>Hỗ trợ tư vấn chọn giấy thay thế tương đương khi một mã tạm hết hàng.</p>
      HTML
    }
  ].freeze
end
