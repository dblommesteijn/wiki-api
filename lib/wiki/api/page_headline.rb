# frozen_string_literal: true

module Wiki
  module Api
    # Headline for a page (class="mw-healine")
    class PageHeadline
      require 'json'

      LEVEL = %w[text h1 h2 h3 h4 h5 h6].freeze

      attr_accessor :name, :block, :parent, :headlines, :level

      def initialize(options = {})
        self.name = options[:name] if options.include?(:name)
        self.parent = options[:parent] if options.include?(:parent)
        self.level = options[:level] if options.include?(:level)
        options[:headlines] ||= []
        self.headlines ||= {}

        # store elements in a block
        self.block = PageBlock.new(parent: self)
        if options[:headlines].include?(name)
          options[:headlines][name].each do |element|
            block << element
          end
        end

        # collect nested headlines
        headlines = options[:headlines]
        # remove self from list
        headlines.delete(name)
        nested_headlines = self.nested_headlines(headlines, name, level)

        # iterate nested headlines, and call recursive
        nested_headlines.each do |headline_name, value|
          level = LEVEL.index(value.first.first.previous.name)
          self.headlines[headline_name] =
            PageHeadline.new(parent: self, name: headline_name, headlines:, level:)
        end
      end

      def elements
        block.elements
      end

      def type
        block.elements.first.first.previous.name
      end

      # get headline by name
      def headline(name)
        name = name.downcase.gsub(' ', '_')
        self.headlines.select do |k, _v|
          k.downcase.start_with?(name)
        end.values
      end

      def headline_in_depth(name, depth = 1)
        name = name.downcase.gsub(' ', '_')
        ret = []

        self.headlines.each do |k, v|
          ret << v if k.downcase.start_with?(name)
          next if v.headlines.empty?

          if depth.positive?
            q = v.headline_in_depth(name, (depth - 1))
            ret.concat(q)
          end
        end
        ret
      end

      # headline exists for current headline
      def has_headline?(name)
        name = name.downcase.gsub(' ', '_')
        self.headlines.each_key do |k|
          return true if k.downcase.start_with?(name)
        end
        false
      end

      def to_hash
        ret = { name:, headlines: [], type: }
        self.headlines.each_value do |headline|
          ret[:headlines] << headline.to_hash
        end
        ret
      end

      def to_pretty_json
        JSON.pretty_generate(to_hash)
      end

      protected

      # filter nested headlines (elements) from a parent headline (by name)
      def nested_headlines(headlines, _name, original_level)
        ret = {}
        init_level = nil
        # iterate headlines, skip already done onces
        # headlines.drop(headline_index + 1).each do |headline|
        headlines.to_a.each do |name, value|
          level = LEVEL.index(value.first.first.previous.name)
          init_level ||= level
          # lower level indicate nest end
          break if level <= original_level
          break if level < init_level
          # higher level indicates nested items, these will be processed recursive
          next if init_level != level

          ret[name] = value
        end
        ret
      end
    end
  end
end
