module Wiki
  module Api

    class Page

      attr_accessor :name, :parsed_page

      def initialize(options={})
        self.name = options[:name] if options.include? :name
        @connect = Wiki::Api::Connect.new
      end

      def headlines
        self.parsed_page ||= @connect.page self.name
        self.parsed_page.xpath("//span[@class='mw-headline']")
      end

      def blocks
        self.parsed_page ||= @connect.page self.name
        self.parse_blocks self.parsed_page.xpath("//span[@class='mw-headline']")
      end

      def headline_block headline_name
        self.parsed_page ||= @connect.page self.name
        xs = self.parse_blocks self.parsed_page.xpath("//span[@class='mw-headline']").reject{|t| t.attributes["id"].value != headline_name }
        return [] if xs.empty?
        xs.values.flatten
      end

      def reset!
        self.parse_page = nil
      end

      protected
      def parse_blocks xs
        result = {}
        xs.each do |x|
          # capture first element name
          headline ||= x.attributes["id"].value
          element = x.parent.next
          elements = []
          # iterate text until next headline
          while true do
            elements << element
            element = element.next
            break if element.nil? || element.to_html.include?("mw-headline")
          end
          h = headline #.downcase.to_sym
          result[h] ||= [] 
          result[h] << elements
        end
        result
      end


    end

  end
end