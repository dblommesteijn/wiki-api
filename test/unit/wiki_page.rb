require 'rubygems'
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/../../lib/wiki/api")


class WikiConnect < Test::Unit::TestCase

  CONFIG = { uri: "http://en.wiktionary.org" }

  def setup
    Wiki::Api::Connect.config = CONFIG
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
      page.headlines.each do |headline|
        assert headline.is_a?(String)
      end
      assert page.headlines.include?(page_name), "expected headline: #{page_name}"
    else
      # NOTE: no headlines found!
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
