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
  end

  def test_page_headers
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
    headlines = page.headlines
    unless headlines.empty?
      page.headlines.each do |headline|
        puts headline
        assert (headline.attributes["class"].value == "mw-headline"), "expected mw-headline class"
      end
    else
      # NOTE: no headlines found!
    end
  end

  def test_page_blocks
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
    blocks = page.blocks
    unless blocks.empty?
      page.blocks.each do |headline, element_groups|
        puts "---- Headline: #{headline} --------------------"
        element_groups.each_with_index do |element_group, i|
          puts "---- Group: #{i}--------------------"
          element_group.each do |element|
            puts element.class
            puts element.text
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

    puts "---------------- test_page_single_block"

    elements = page.headline_block "Editing_Wiktionary"
    elements.each do |element|
      puts element.class
      puts element.text
    end


    
  end


end
