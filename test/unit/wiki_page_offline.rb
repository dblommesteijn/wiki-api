require 'rubygems'
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/../../lib/wiki/api")

#
# Testing the parsing of URI (with a predownloaded HTML file):
#   /files/Wiktionary_Welcome,_newcomers.html (2013-03-27)
#
# Online equivalent:
#   https://en.wiktionary.org/wiki/Wiktionary:Welcome,_newcomers
#

class WikiConnectOffline < Test::Unit::TestCase

  CONFIG = { file: File.expand_path(File.dirname(__FILE__) + "/files/Wiktionary_Welcome,_newcomers.html") }
  #CONFIG = { uri: "http://en.wiktionary.org" }

  def setup
    Wiki::Api::Page.config = CONFIG
    # Wiki::Api::Connect.config = CONFIG
  end

  def teardown
  end

  def test_page_get
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
    assert page.to_html.is_a?(String), "expected a String"
  end

  def test_page_headlines
    page_name = "Wiktionary:Welcome,_newcomers"
    page = Wiki::Api::Page.new name: page_name
    headlines = page.headlines
    unless headlines.empty?
      # iterate headlines, and test for strings
      page.headlines.each do |headline|
        assert headline.is_a?(String)
      end

      # test absolute headlines
      assert page.headlines.include?(page_name), "expected headline: #{page_name}"
      assert page.headlines.include?("Editing_Wiktionary"), "expected headline: Editing_Wiktionary"
      assert page.headlines.include?("Norms_and_etiquette"), "expected headline: Norms_and_etiquette"
      assert page.headlines.include?("For_more_information"), "expected headline: For_more_information"      
    else
      # NOTE: no headlines found!
      assert false, "no headlines found"
    end
  end

  def test_page_blocks
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
    blocks = page.blocks
    unless blocks.empty?
      page.blocks.each do |headline, element_groups|
        # puts "---- Headline: #{headline} --------------------"
        element_groups.each_with_index do |element_group, i|
          # puts "---- Group: #{i}--------------------"
          element_group.each do |element|
            # puts element.class
            # puts element.text
          end

          #element_group[0].text
        end
        #assert (headline.attributes["class"].value == "mw-headline"), "expected mw-headline class"
      end
    else
      # NOTE: no headlines found!
    end
  end

  def test_page_single_block
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"

    elements = page.headline_block "Editing_Wiktionary"
    elements.each do |element|
      # puts element.class
      # puts element.text
    end
    
  end

  def test_page_first_part
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
    elements = page.headline_block "Wiktionary:Welcome,_newcomers"

    elements.each do |element|
      # puts element.class
      # puts element.text
    end

  end


end
