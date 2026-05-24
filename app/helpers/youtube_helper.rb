# frozen_string_literal: true

module YoutubeHelper
  # Trả về URL embed https hoặc nil nếu không parse được.
  def youtube_embed_url(raw)
    id = youtube_video_id(raw)
    return nil unless id

    "https://www.youtube.com/embed/#{id}"
  end

  def youtube_video_id(raw)
    s = raw.to_s.strip
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
end
