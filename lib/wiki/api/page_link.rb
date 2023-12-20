# frozen_string_literal: true

module Wiki
  module Api
    # Link on a wiki page (a href=xxx)
    class PageLink
      attr_accessor :element, :parent

      def initialize(options = {})
        self.element = options[:element] if options.include?(:element)
        self.parent = options[:parent] if options.include?(:parent)
      end

      def to_text
        Wiki::Api::Util.element_to_text(element)
      end

      def uri
        # lookup the root parent, and get connector info
        host = Wiki::Api::Util.parent_root(self).connect.uri
        href_value = element.attributes['href'].value
        URI.parse("#{host}#{href_value}")
      end

      def title
        # skip links with no title
        return '' if element.attributes['title'].nil?

        element.attributes['title'].value
      end

      def html
        "<a href=\"#{uri}\" alt=\"#{title}\">#{title}</a>"
      end
    end
  end
end
