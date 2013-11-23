module Gliffy
  class User
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
  end
end
