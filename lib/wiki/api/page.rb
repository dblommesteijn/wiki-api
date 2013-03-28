module Wiki
  module Api

    class Page

      attr_accessor :name, :parsed_page

      def initialize(options={})
        self.name = options[:name] if options.include? :name
        @@config ||= nil
        if @@config.nil?
          # use the connection to collect HTML pages for parsing
          @connect = Wiki::Api::Connect.new
        else
          # using a local HTML file for parsing
        end
      end

      def headlines
        headlines = []
        self.parse_blocks.each do |headline_name, elements|
          headline = PageHeadline.new name: headline_name
          elements.each do |element|
            # nokogiri element
            headline.block << element
          end
          headlines << headline
        end
        headlines
      end

      def headline headline_name
        headlines = []
        self.parse_blocks(headline_name).each do |headline_name, elements|
          headline = PageHeadline.new name: headline_name
          elements.each do |element|
            # nokogiri element
            headline.block << element
          end
          headlines << headline
        end
        headlines
      end



      def to_html
        self.load_page!
        self.parsed_page.to_xhtml indent: 3, indent_text: " "
      end

      def reset!
        self.parse_page = nil
      end

      class << self
        def config=(config = {})
          @@config = config
        end
      end

      protected

      def load_page!
        if @@config.nil?
          self.parsed_page ||= @connect.page self.name
        elsif self.parsed_page.nil?
          f = File.open(@@config[:file])
          self.parsed_page = Nokogiri::HTML(f)
          f.close
        end
      end


      # parse blocks
      def parse_blocks headline_name = nil
        self.load_page!
        result = {}

        # get headline nodes by span class
        xs = self.parsed_page.xpath("//span[@class='mw-headline']")
        # filter single headline by name
        xs = xs.reject{|t| t.attributes["id"].value != headline_name } unless headline_name.nil?

        # NOTE: first_part has no id attribute and thus cannot be filtered or processed within xpath (xs)
        if headline_name == self.name || headline_name.nil?
          x = self.first_part
          result[self.name] ||= [] 
          result[self.name] << (self.collect_elements(x.parent))
        end

        # append all blocks
        xs.each do |x|
          headline = x.attributes["id"].value
          elements = self.collect_elements x.parent.next
          result[headline] ||= [] 
          result[headline] << elements
        end

        result
      end

      # harvest first part of the page (missing heading and class="mw-headline")
      def first_part
        self.parsed_page ||= @connect.page self.name
        self.parsed_page.search("p").first.children.first
      end

      # collect elements within headlines (not nested properties, but next elements)
      def collect_elements element
        # capture first element name
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