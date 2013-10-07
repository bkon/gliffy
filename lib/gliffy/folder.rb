require 'uri'

module Gliffy
  class Folder
    attr_reader :name, :path
    attr_reader :owner, :parent
    attr_reader :folders

    def self.load(owner, node)
      Gliffy::Folder.new(
        owner,
        node.string('g:name'),
        node.string('g:path'),
        node.nodes('g:folder').map {|n| Gliffy::Folder.load(owner, n)}
      )
    end

    def initialize(owner, name, path, folders)
      @owner = owner
      @name = name
      @path = path

      @folders = folders
      @folders.each do |f|
        f.parent = self
      end
    end

    def parent=(parent)
      if path != parent.path + "/" + name then
        raise "Invalid parent"
      end

      @parent = parent
    end

    def create_document(name)
      api.create_document(name, Gliffy::Document::TYPE_DIAGRAM, nil, path)
    end

    def documents
      @documents ||= load_documents
    end

    def root?
      path == "ROOT"
    end

    # observer callback
    def update(event, target)
      case event
      when :delete
        @documents = @documents.delete_if { |element| element == target }
      else
        raise ArgumentError.new(event)
      end
    end

    private

    def api
      owner.api
    end

    def account_id
      owner.id
    end

    def load_documents
      response = api.get_documents_in_folder(path)

      response
        .nodes('//g:document')
        .map { |n| load_document n }
    end

    def load_document(n)
      document = Gliffy::Document.load(owner, n)
      document.add_observer(self)
      document
    end
  end
end
