require 'uri'

module Gliffy
  class Folder
    include Observable

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
        f.add_observer(self)
      end

      @is_deleted = false
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

    def create_folder(name)
      if has_child? name
        raise ArgumentError.new(name)
      end

      new_path = path + "/" + name

      api.create_folder(new_path)

      new_folder = Folder.new(owner, name, new_path, [])
      folders.push(new_folder)
      new_folder
    end

    def documents
      @documents ||= load_documents
    end

    def root?
      path == "ROOT"
    end

    def deleted?
      @is_deleted
    end

    def has_child?(name)
      normalized_name = name.downcase
      not folders.index do |child|
        child.name.downcase == normalized_name
      end.nil?
    end

    # observer callback
    def update(event, target)
      case event
      when :document_removed, :document_deleted
        @documents = @documents.delete_if { |element| element == target }
        target.delete_observer(self)
      when :document_added
        @documents.push target
        target.add_observer(self)
      when :folder_deleted
        @folders = @folders.delete_if { |element| element == target }
      else
        raise ArgumentError.new(event)
      end
    end

    def delete
      api.delete_folder(path)
      @is_deleted = true

      changed
      notify_observers :folder_deleted, self
    end

    private

    def api
      owner.api
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
