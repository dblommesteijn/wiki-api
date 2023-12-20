# frozen_string_literal: true

module Wiki
  module Api
    # Collection of elements for segmented per headline
    class PageBlock
      attr_accessor :elements, :parent

      def initialize(options = {})
        self.parent = options[:parent] if options.include?(:parent)
        self.elements = []
      end

      def <<(value)
        # value.first.previous.name
        elements << value
      end

      def to_texts
        texts = []
        elements.flatten.each do |element|
          text = Wiki::Api::Util.element_to_text(element) if element.is_a?(Nokogiri::XML::Element)
          next if text.nil?
          next if text.empty?

          texts << text
        end
        texts
      end

      def list_items
        # TODO: perhaps we should wrap the elements with objects, and request a li per element??
        search('li').map do |list_item|
          PageListItem.new(parent: self, element: list_item)
        end
      end

      def links
        # TODO: perhaps we should wrap the elements with objects, and request a li per element??
        search('a').map do |a|
          PageLink.new(parent: self, element: a)
        end
      end

      protected

      def search *paths
        elements.flatten.flat_map do |element|
          element.search(*paths)
        end.reject(&:nil?)
      end
    end
  end
end
