module Gliffy
  class API::Error < Exception
    attr_reader :code, :text

    def initialize(code, text)
      @code = code
      @text = text
    end

    def to_s
      "#{code.to_i}: #{text}"
    end
  end
end
