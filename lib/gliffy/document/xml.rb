module Gliffy
  class Document::XML
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def content
      api.raw(
        "/accounts/#{account_id}/documents/#{document_id}.xml",
        :action => 'get'
      )
    end

    private

    def api
      document.api
    end

    def document_id
      document.id
    end

    def account_id
      account.id
    end

    def account
      document.owner
    end
  end
end
