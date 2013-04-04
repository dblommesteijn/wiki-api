module Wiki
  module Api

    class PageListItem

      attr_accessor :element, :parent

      def initialize options={}
        self.element = options[:element] if options.include? :element
        self.parent = options[:parent] if options.include? :parent
      end

      def to_text
        Wiki::Api::Util.element_to_text self.element
      end

      def links
        self.search("a").map do |a|
          PageLink.new parent: self, element: a
        end
      end

      protected

      def search *paths
        self.element.search(*paths)
      end


    end

  end
end