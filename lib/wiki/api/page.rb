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

      def headline_block headline
        self.parsed_page ||= @connect.page self.name
        xs = self.parsed_page.xpath("//span[@class='mw-headline']").reject{|t| t.attributes["id"].value != headline }
        element = xs.first.parent.next

        elements = []
        # iterate text until next headline
        while true do
          elements << element
          element = element.next
          break if element.to_html.include? "mw-headline"
        end
        elements
      end


      def blocks
        self.parsed_page ||= @connect.page self.name
        xs = self.parsed_page.xpath("//span[@class='mw-headline']").reject{|t| t.attributes["id"].value != headline }
        raise "not implemented!!!"
        # elements = {}
        # self.headlines.each do |headline|
                  
        #   elements 

        # end
        # elements
      end


      def connect
        @connect
      end

      class << self
        
        def to_text element
          element.map{|t| t.text}
        end

      end

    end

  end
end