module Gliffy
    class API::Response
      def initialize(base)
        @base = base
      end

      def content
        @base.content
      end

      def nodes(path)
        @base.xpath(path, namespaces).map { |n| Gliffy::API::Response.new(n) }
      end

      def node(path)
        Gliffy::API::Response.new(@base.at_xpath(path, namespaces))
      end

      def string(path)
        node(path).content
      end

      def integer(path)
        string(path).to_i
      end

      def timestamp(path)
        parse_timestamp(string(path))
      end

      def exists(path)
        !@base.at_xpath(path, namespaces).nil?
      end

      def error?
        exists("//g:response[@success='false']")
      end

      private

      # Gliffy XML namespace to be used in XPath expressions
      def namespaces
        { "g" => "http://www.gliffy.com" }
      end

      # As opposed to UNIX timestamp,  timestamps returned by Gliffy API
      # are in  milliseconds, so  we should divide  them by  1000 before
      # converting to real datetime objectsq
      def parse_timestamp(value)
        Time.at(value.to_i / 1000).to_datetime
      end
    end
end
