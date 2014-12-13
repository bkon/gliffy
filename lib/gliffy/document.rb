require "observer"

module Gliffy
  class Document
    include Observable

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

    def move(folder)
      api.move_document(id, folder.path)

      changed
      notify_observers :document_removed, self
      folder.update :document_added, self
    end

    def delete
      api.delete_document(id)
      @is_deleted = true

      changed
      notify_observers :document_deleted, self
    end

    def deleted?
      @is_deleted
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

    # Use the png_url in Facade to retrieve the direct URL to a diagram PNG, not the actual contents of the PNG.
    def png_url
      api.png_url id
    end

    def public?
      is_public
    end

    def public=(value)
      api.update_document_metadata(id, nil, value)
      @is_public = value
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

      @is_deleted = false
    end
  end
end
