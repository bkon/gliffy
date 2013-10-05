module Gliffy
  class Document::Presentation::XML < Document::Presentation
    def content
      api.raw(
        "/accounts/#{account_id}/documents/#{document_id}.xml",
        :action => 'get'
      )
    end
  end
end
