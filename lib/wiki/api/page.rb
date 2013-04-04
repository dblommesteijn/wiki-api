module Wiki
  module Api

    # MediaWiki Page, collection of all html information plus it's page title
    class Page

      attr_accessor :name, :parsed_page, :uri, :parent

      def initialize(options={})
        self.name = options[:name] if options.include? :name
        self.uri = options[:uri] if options.include? :uri
        @connect = Wiki::Api::Connect.new uri: uri
      end

      def connect
        @connect
      end



      # collect all headlines, keep original page formatting
      def headlines
        self.parse_blocks
      end

      # collect headlines by given name, this will flatten the nested headlines
      def flat_headlines_by_name headline_name
        # TODO: implement flattening of headlines within the root headline
        # ALT:  breath search option in the root of the first headline
        self.parse_blocks(headline_name)
      end


      def to_html
        self.load_page!
        self.parsed_page.to_xhtml indent: 3, indent_text: " "
      end

      def reset!
        self.parse_page = nil
      end

      

      def load_page!
        self.parsed_page ||= @connect.page self.name
      end


      # parse blocks
      def parse_blocks headline_name = nil
        self.load_page!
        result = {}

        # get headline nodes by span class
        xs = self.parsed_page.xpath("//span[@class='mw-headline']")

        # filter single headline by name (ignore case)
        xs = self.filter_headline xs, headline_name unless headline_name.nil?

        # NOTE: first_part has no id attribute and thus cannot be filtered or processed within xpath (xs)
        if headline_name.nil? || headline_name.start_with?(self.name.downcase)
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

        # check for type
        level = PageHeadline::LEVEL.index result.first[1].first.first.previous.name
        # capture all, starting at root
        if level == 0
          name = result.first[0]
        # create a root placeholder, which contains searched headlines
        else 
          level = 0
          name = "root_placeholder"
        end

        # create root object
        PageHeadline.new parent: self, name: name, headlines: result, level: level
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

      def filter_headline xs, headline_name
        # transform name to a wiki_id (downcase and space replace with underscore)
        headline_name = headline_name.downcase.gsub(" ", "_")
        # reject not matching id's
        xs.reject do |t| 
          !t.attributes["id"].value.downcase.start_with?(headline_name)
        end
      end

    end

  end
end