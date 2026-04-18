# frozen_string_literal: true

module ProductsHelper
  # Dữ liệu JSON cho gallery (ảnh chính + thumbnail).
  def product_gallery_items(product)
    product.images.select { |im| im.file.attached? }.map do |im|
      {
        url: url_for(im.file),
        thumb: url_for(im.file.variant(resize_to_fill: [168, 168])),
        alt: (im.caption.presence || product.name).to_s
      }
    end
  end
end
