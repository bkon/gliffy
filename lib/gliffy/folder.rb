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

    def documents
      @documents ||= load_documents
    end

    def root?
      path == "ROOT"
    end

    private

    def api
      owner.api
    end

    def account_id
      owner.id
    end

    def escaped_path
      path.gsub(' ', '+')
    end

    def load_documents
      # Path  is alphanumeric  +  spaces and  '/'.   Spaces should  be
      # escaped; slashes should NOT be escaped.
      url = "/accounts/#{account_id}/folders/#{escaped_path}/documents.xml"
      response = api.get(url,
                         :action => "get")

      response
        .nodes('//g:document')
        .map { |n| Gliffy::Document.load(owner, n) }
    end
  end
end
