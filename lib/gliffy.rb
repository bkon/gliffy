require 'date'

require 'gliffy/api'
require 'gliffy/api/error'
require 'gliffy/api/facade'
require 'gliffy/api/response'
require 'gliffy/account'
require 'gliffy/document'
require 'gliffy/document/png'
require 'gliffy/document/svg'
require 'gliffy/document/xml'
require 'gliffy/folder'

require 'gliffy/oauth/helper'

module Gliffy
  class << self
    def default_application_name
      "Gliffy Ruby Gem"
    end

    # some calls (e.g. OAuth token  generation) should be done through
    # secure   HTTPS;  other   calls   (e.g.   actions  performed   by
    # non-privileged accounts) should be done though plain HTTP
    #
    # We're using protocol-relative URL here.
    def api_root
      '//www.gliffy.com/api/1.0'
    end

    # We're using protocol-relative (//hosrname/path/ format) URL here.
    def web_root
      '//www.gliffy.com'
    end
  end
end
