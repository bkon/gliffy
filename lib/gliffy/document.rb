module Gliffy
  class Document
    TYPE_DIAGRAM = "diagram"

    attr_reader :owner
    attr_reader :id
    attr_reader :is_public
    attr_reader :versions
    attr_reader :name
    attr_reader :modified, :created, :published

    def self.load(owner, node)
      @loaded ||= {}

      id = node.integer('@id')
      if not @loaded.has_key? id then
        @loaded[id] = Gliffy::Document.new(
          owner,
          id,
          :is_public => node.exists('@is-public'),
          :versions => node.integer('@num-versions'),
          :name => node.string('g:name'),
          :modified => node.timestamp('g:mod-date'),
          :created => node.timestamp('g:create-date'),
          :published => node.timestamp('g:published-date')
          )
      end

      @loaded[id]
    end

    def self.clear_cache
      @loaded = {}
    end

    def rename(new_name)
      @name = new_name

      api.update_document_metadata(id, new_name, nil)
    end

    def delete
      api.delete_document(id)
    end

    def editor(return_url, return_text)
      api.web(
        "/gliffy/",
        :launchDiagramId => id,
        :returnURL => return_url,
        :returnButtonText => return_text
      )
    end

    def svg
      Document::Presentation::SVG.new(self)
    end

    def xml
      Document::Presentation::XML.new(self)
    end

    def png
      Document::Presentation::PNG.new(self)
    end

    def public?
      is_public
    end

    def api
      owner.api
    end

    private

    def initialize(owner, id, params)
      @owner = owner
      @id = id

      @is_public = params[:is_public]
      @versions = params[:versions]
      @name = params[:name]
      @modified = params[:modified]
      @created = params[:created]
      @published = params[:published]
    end
  end
end
