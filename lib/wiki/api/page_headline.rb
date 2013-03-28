module Wiki
  module Api

    class PageHeadline

      attr_accessor :name, :block

      def initialize options={}
        self.name = options[:name] if options.include? :name
        self.block = PageBlock.new
      end

      def elements
        self.block.elements
      end



    end

  end
end