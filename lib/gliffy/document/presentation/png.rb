module Gliffy
  class Document::Presentation::PNG < Document::Presentation
    SIZE_THUMBNAIL = "T"
    SIZE_SMALL = "S"
    SIZE_MEDIUM = "M"
    SIZE_FULL = "L"

    def content(size)
      api.raw(
        "/accounts/#{account_id}/documents/#{document_id}.png",
        :action => 'get',
        :size => size
      )
    end

    def thumbnail
      content(SIZE_THUMBNAIL)
    end

    def small
      content(SIZE_SMALL)
    end

    def medium
      content(SIZE_MEDIUM)
    end

    def full
      content(SIZE_FULL)
    end
  end
end
