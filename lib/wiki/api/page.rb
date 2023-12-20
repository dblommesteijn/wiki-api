# frozen_string_literal: true

module Wiki
  module Api
    # MediaWiki Page, collection of all html information plus it's page title
    class Page
      attr_accessor :name, :parsed_page, :uri, :parent

      def initialize(options = {})
        self.name = options[:name] if options.include?(:name)
        self.uri = options[:uri] if options.include?(:uri)
        @connect = Wiki::Api::Connect.new(uri:)
      end

      attr_reader :connect

      # collect all headlines, keep original page formatting
      def root_headline
        parse_blocks
      end

      # # collect headlines by given name, this will flatten the nested headlines
      # def flat_headlines_by_name headline_name
      #   raise "not yet implemented!"
      #   # TODO: implement flattening of headlines within the root headline
      #   # ALT:  breath search option in the root of the first headline
      #   self.parse_blocks(headline_name)
      # end

      def to_html
        load_page!
        parsed_page.to_xhtml(indent: 3, indent_text: ' ')
      end

      def reset!
        self.parse_page = nil
      end

      def load_page!
        self.parsed_page ||= @connect.page(name)
      end

      # parse blocks
      def parse_blocks(headline_name = nil)
        load_page!
        result = {}

        # get headline nodes by span class
        headlines = self.parsed_page.xpath("//span[@class='mw-headline']")

        # filter single headline by name (ignore case)
        headlines = filter_headline(headlines, headline_name) unless headline_name.nil?

        # NOTE: first_part has no id attribute and thus cannot be filtered or processed within xpath (xs)
        if headline_name.nil? || headline_name.start_with?(name.downcase)
          x = first_part
          result[name] ||= []
          result[name] << (collect_elements(x.parent))
        end

        # append all blocks
        headlines.each do |headline|
          headline_value = headline.attributes['id'].value
          elements = collect_elements(headline.parent.next)
          result[headline_value] ||= []
          result[headline_value] << elements
        end

        # create root object
        PageHeadline.new(parent: self, name: result.first[0], headlines: result, level: 0)
      end

      # harvest first part of the page (missing heading and class="mw-headline")
      def first_part
        self.parsed_page ||= @connect.page(name)
        self.parsed_page.search('p').first.children.first
      end

      # collect elements within headlines (not nested properties, but next elements)
      def collect_elements(element)
        # capture first element name
        elements = []
        # iterate text until next headline
        loop do
          elements << element
          element = element.next
          break if element.nil? || element.to_html.include?('class="mw-headline"')
        end
        elements
      end

      def filter_headline(xs, headline_name)
        # transform name to a wiki_id (downcase and space replace with underscore)
        headline_name = headline_name.downcase.gsub(' ', '_')
        # reject not matching id's
        xs.select do |t|
          t.attributes['id'].value.downcase.start_with?(headline_name)
        end
      end
    end
  end
end
