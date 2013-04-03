module Wiki
  module Api

    class Util

      class << self

        def element_to_text element
          raise "not an element" unless element.is_a? Nokogiri::XML::Element
          self.clean_text element.text
        end

        def element_filter_lists element
          raise "not an element" unless element.is_a? Nokogiri::XML::Element
          result = {}
          element.search("li").each_with_index do |li, i|
            li.children.each do |child|
              result[i] ||= []
              result[i] << self.clean_text(child.text)
            end
          end
          result.map{|k,v| v.join("")}
        end


        protected
        def clean_text text
          text.gsub(/\n/, " ").squeeze(" ").gsub(/\s(\W)/, '\1').gsub(/(\W)\s/, '\1 ').strip
        end

      end

    end
  end
end