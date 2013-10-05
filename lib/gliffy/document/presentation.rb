module Gliffy
  class Document::Presentation
    attr_reader :document

    def initialize(document)
      @document = document
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
