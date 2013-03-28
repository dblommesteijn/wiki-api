module Wiki
  module Api

    class PageLink

      attr_accessor :element

      def initialize options={}
        self.element = options[:element] if options.include? :element
      end

      def to_text
        Wiki::Api::Util.element_to_text self.element
      end

      def uri
        host = Wiki::Api::Connect.config[:uri]
        element_value = self.element.attributes["href"].value
        URI.parse "#{host}#{element_value}"
      end

      def title
        self.element.attributes["title"].value
      end

      def html
        "<a href=\"#{self.uri}\" alt=\"#{self.title}\">#{self.title}</a>"
      end

    end

  end
end