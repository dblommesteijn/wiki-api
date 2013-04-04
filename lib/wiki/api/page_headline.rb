module Wiki
  module Api

    # Headline for a page (class="mw-healine")
    class PageHeadline

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
        # remove self from list
        headlines = options[:headlines].reject{|k,v| k == self.name}

        # iterate passed headlines (nested)
        headlines.each do |headline_name, elements|
          level = LEVEL.index elements.first.first.previous.name
          # iterate until reached same level as current headline (h2 == h2 => should not be nested but the next)
          break if level <= self.level
          # append to nested headline list
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

      def to_hash
        ret = {name: self.name, headlines: [], type: self.type}
        self.headlines.each do |headline_name, headline|
          ret[:headlines] << headline.to_hash
        end
        ret
      end


    end

  end
end