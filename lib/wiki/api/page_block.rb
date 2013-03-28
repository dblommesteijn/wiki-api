module Wiki
  module Api

    class PageBlock

      attr_accessor :elements

      def initialize options={}
        self.elements = []
      end

      def << value
        self.elements << value
      end

      def to_texts
        # TODO: perhaps we should wrap the elements with objects??
        texts = []
        self.elements.flatten.each do |element|
          text = Wiki::Api::Util.element_to_text element if element.is_a? Nokogiri::XML::Element
          next if text.nil?
          next if text.empty?
          texts << text
        end
        texts
      end

      def list_items
        # TODO: perhaps we should wrap the elements with objects, and request a li per element??
        self.search("li").map do |list_item|
          PageListItem.new element: list_item
        end
      end

      def links
        # TODO: perhaps we should wrap the elements with objects, and request a li per element??
        self.search("a").map do |a|
          PageLink.new element: a
        end
      end

      protected

      def search *paths
        self.elements.flatten.flat_map do |element|
          element.search(*paths)
        end.reject{|t| t.nil?}
      end

    end

  end
end