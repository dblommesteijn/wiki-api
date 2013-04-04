# encoding: utf-8

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

class WikiPageOfflinePage < Test::Unit::TestCase

  # this global is required to resolve URIs (MediaWiki uses relative paths in their links)
  URI_CONFIG = { uri: "http://en.wiktionary.org" }
  # use local file for test loading
  PAGE_CONFIG = { file: File.expand_path(File.dirname(__FILE__) + "/files/Wiktionary_program.html") }

  def setup
    # NOTE: comment Page.config, to use the online MediaWiki instance
    Wiki::Api::Connect.config = URI_CONFIG
    Wiki::Api::Connect.config.merge! PAGE_CONFIG
  end

  def teardown
  end

  # test simple page invocation
  def test_headlines_nested
    page = Wiki::Api::Page.new name: "program"

    # load page
    assert page.is_a?(Wiki::Api::Page), "expected Page object"
    headline = page.headlines
    assert headline.is_a?(Wiki::Api::PageHeadline), "expected PageHeadline object"
    assert headline.name == "program", "expected developer headline"

    # search nested headline: english   
    english = headline.headline("english").first
    assert english.is_a?(Wiki::Api::PageHeadline), "expected PageHeadline object"

    # search nested headline: noun
    noun = english.headline("noun").first
    assert noun.is_a?(Wiki::Api::PageHeadline), "expected PageHeadline object"

    # get block
    block = noun.block
    assert block.is_a?(Wiki::Api::PageBlock), "expected PageBlock object"

    # list items
    block.list_items.each do |list_item|
      assert list_item.is_a?(Wiki::Api::PageListItem), "expected PageListItem object"
      # links
      list_item.links.each do |link|
        assert link.is_a?(Wiki::Api::PageLink), "expected PageListItem object"
      end
    end

    # links
    block.links.each do |link|
      assert link.is_a?(Wiki::Api::PageLink), "expected PageListItem object"
    end
  end


  def test_headlines_search
    # puts "---------------------------------"

    start = Time.now.to_f

    page = Wiki::Api::Page.new name: "program"
    assert page.is_a?(Wiki::Api::Page), "expected Page object"

    headlines = page.headline("noun")
    assert headlines.is_a?(Wiki::Api::PageHeadline), "expected PageHeadline object"
    assert headlines.name == "root_placeholder", "expected a placeholder"

    headlines.headlines.each do |headline_name, headline|
      assert headline_name.is_a?(String), "expected a string"
      assert headline.name == headline_name, "shorthand name should be equal"
    end

    puts Time.now.to_f - start
    start = Time.now.to_f


    page = Wiki::Api::Page.new name: "program"
    assert page.is_a?(Wiki::Api::Page), "expected Page object"

    headlines = page.headlines
    assert headlines.is_a?(Wiki::Api::PageHeadline), "expected PageHeadline object"
    # assert headlines.name == "root_placeholder", "expected a placeholder"

    headlines.headlines.each do |headline_name, headline|
      assert headline_name.is_a?(String), "expected a string"
      assert headline.name == headline_name, "shorthand name should be equal"
    end

    puts Time.now.to_f - start


  end
  
 

end