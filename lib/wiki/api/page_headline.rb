module Wiki
  module Api

    # Headline for a page (class="mw-healine")
    class PageHeadline

      require 'json'

      LEVEL = ["text", "h1", "h2", "h3", "h4", "h5", "h6"]

      attr_accessor :name, :block, :parent, :headlines, :level

      def initialize options={}
        self.name = options[:name] if options.include? :name
        self.parent = options[:parent] if options.include? :parent
        self.level = options[:level] if options.include? :level
        options[:headlines] ||= []
        self.headlines ||= {}

        # store elements in a block
        self.block = PageBlock.new parent: self
        if options[:headlines].include? self.name
          options[:headlines][self.name].each do |element|
            self.block << element
          end
        end

        # collect nested headlines
        headlines = options[:headlines]
        # remove self from list
        headlines.delete self.name
        nested_elements = self.nested_elements headlines, self.name, self.level

        # iterate nested headlines, and call recursive
        nested_elements.each do |headline_name, value|

          level = LEVEL.index value.first.first.previous.name
          self.headlines[headline_name] = (PageHeadline.new parent: self, name: headline_name, headlines: headlines, level: level)
        end
      end

      def elements
        self.block.elements
      end

      def type
        self.block.elements.first.first.previous.name
      end

      def headline name
        name = name.downcase.gsub(" ", "_")
        self.headlines.reject do |k,v| 
          !k.downcase.start_with?(name)
        end.values()
      end

      def headline_by_name name, depth = 1
        name = name.downcase.gsub(" ", "_")
        ret = []
        self.headlines.each do |k,v|
          ret << v if k.downcase.start_with?(name)
          next if v.headlines.empty?
          if depth > 0
            q = v.headline_by_name name, (depth - 1)
            ret.concat q
          end
        end
        ret
      end

      def to_hash
        ret = {name: self.name, headlines: [], type: self.type}
        self.headlines.each do |headline_name, headline|
          ret[:headlines] << headline.to_hash
        end
        ret
      end

      def to_pretty_json
        JSON.pretty_generate self.to_hash
      end

      protected 

      # filter nested headlines (elements) from a parent headline (by name)
      def nested_elements headlines, name, original_level
        ret = {}
        init_level = nil
        # iterate headlines, skip already done onces
        #headlines.drop(headline_index + 1).each do |headline|
        headlines.to_a.each do |name, value|
          level = LEVEL.index value.first.first.previous.name
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