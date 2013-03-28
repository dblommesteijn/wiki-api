module Wiki
  module Api

    class Util

      class << self

        def element_to_text element
          raise "not an element" unless element.is_a? Nokogiri::XML::Element
          element.text.gsub(/\n/, " ").squeeze(" ").gsub(/\s(\W)/, '\1').gsub(/(\W)\s/, '\1 ').strip
        end

      end

    end

  end
end