module Wiki
  module Api

    class Page

      attr_accessor :name, :parsed_page

      def initialize(options={})
        self.name = options[:name] if options.include? :name
        @connect = Wiki::Api::Connect.new
      end

      def connect
        @connect
      end

      def headlines
        self.blocks.keys
      end

      def blocks
        self.parsed_page ||= @connect.page self.name
        self.parse_blocks
      end

      def headline_block headline_name
        self.parsed_page ||= @connect.page self.name
        xs = self.parse_blocks headline_name
        return [] if xs.empty?
        xs[headline_name].flatten
      end

      def to_html
        self.parsed_page ||= @connect.page self.name
        self.parsed_page.to_xhtml indent: 3, indent_text: " "
      end

      def reset!
        self.parse_page = nil
      end

      protected

      # harvest first part of the page (missing heading and class="mw-headline")
      def first_part
        self.parsed_page ||= @connect.page self.name
        self.parsed_page.search("p").first.children.first
      end

      # parse blocks
      def parse_blocks headline_name = nil
        result = {}

        # get headline nodes by span class
        xs = self.parsed_page.xpath("//span[@class='mw-headline']")
        # filter single headline by name
        xs = xs.reject{|t| t.attributes["id"].value != headline_name } unless headline_name.nil?

        # NOTE: first_part has no id attribute and thus cannot be filtered or processed within xpath (xs)
        if headline_name != self.name
          x = self.first_part
          elements = self.collect_elements x
          result[self.name] ||= [] 
          result[self.name] << elements
        end

        # append all blocks
        xs.each do |x|
          headline = x.attributes["id"].value
          elements = self.collect_elements x
          result[headline] ||= [] 
          result[headline] << elements
        end

        result
      end

      # collect elements within headlines (not nested properties, but next elements)
      def collect_elements x
        # capture first element name
        element = x.parent.next
        elements = []
        # iterate text until next headline
        while true do
          elements << element
          element = element.next
          break if element.nil? || element.to_html.include?("class=\"mw-headline\"")
        end
        elements
      end


    end

  end
end