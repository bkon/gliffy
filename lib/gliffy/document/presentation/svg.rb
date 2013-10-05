module Gliffy
  class Document::Presentation::SVG < Document::Presentation
    def content
      api.raw(
        "/accounts/#{account_id}/documents/#{document_id}.svg",
        :action => 'get'
      )
    end
  end
end
