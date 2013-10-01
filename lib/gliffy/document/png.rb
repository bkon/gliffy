module Gliffy
  class Document::PNG
    attr_reader :document

    SIZE_THUMBNAIL = "T"
    SIZE_SMALL = "S"
    SIZE_MEDIUM = "M"
    SIZE_FULL = "L"

    def initialize(document)
      @document = document
    end

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

    private

    def api
      document.api
    end

    def account
      document.owner
    end

    def document_id
      document.id
    end

    def account_id
      account.id
    end
  end
end