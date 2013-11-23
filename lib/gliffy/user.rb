module Gliffy
  class User
    include Observable

    attr_reader :username, :email

    def self.load(owner, node)
      Gliffy::User.new(
        owner,
        node.string('g:username'),
        node.string('g:email'),
      )
    end

    def initialize(owner, username, email)
      @owner = owner
      @username = username
      @email = email
    end

    def accessible_folders
      api.folders_accessible_to_user(username)
        .nodes("//g:folders/g:folder")
        .map { |n| Gliffy::Folder.load(owner, n) }
    end

    def delete
      api.delete_user(username)

      changed
      notify_observers :user_deleted, self
    end

    def email=(email)
      api.update_user(username, email, nil, nil)
      @email = email
    end

    def password=(value)
      api.update_user(username, nil, value, nil)
    end

    def admin=(value)
      api.update_user(username, nil, nil, value)
    end

    private

    def api
      owner.api
    end

    def owner
      @owner
    end
  end
end
