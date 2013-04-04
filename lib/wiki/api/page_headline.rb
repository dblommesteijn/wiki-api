module Wiki
  module Api

    # Headline for a page (class="mw-healine")
    class PageHeadline

      attr_accessor :name, :block, :parent

      def initialize options={}
        self.name = options[:name] if options.include? :name
        self.parent = options[:parent] if options.include? :parent
        self.block = PageBlock.new parent: self
      end

      def elements
        self.block.elements
      end



    end

  end
end