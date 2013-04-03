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

class WikiPageObject < Test::Unit::TestCase

  # this global is required to resolve URIs (MediaWiki uses relative paths in their links)
  GLB_CONFIG = { uri: "http://en.wiktionary.org" }

  # use local file for test loading
  PAGE_CONFIG = { file: File.expand_path(File.dirname(__FILE__) + "/files/Wiktionary_Welcome,_newcomers.html") }

  def setup
    # NOTE: comment Page.config, to use the online MediaWiki instance
    Wiki::Api::Page.config = PAGE_CONFIG
    Wiki::Api::Connect.config = GLB_CONFIG
    @page_name = "Wiktionary:Welcome,_newcomers"
  end

  def teardown
  end

  # test simple page invocation
  def test_page_invocation
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
    end
  end

  # test nokogiri elements per headline
  def test_page_elements
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      elements = headline.elements.flatten
      assert !elements.empty?, "expected elements"
      elements.each do |element|
        assert element.is_a?(Nokogiri::XML::Element) || 
          element.is_a?(Nokogiri::XML::Text) ||
          element.is_a?(Nokogiri::XML::Comment), "expected nokogiri internals"
      end
    end
  end

  # test pageblocks for each headline
  def test_page_blocks
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      block = headline.block
      assert block.is_a?(Wiki::Api::PageBlock), "expected block object"
    end
  end

  # test string text from page block
  def test_page_block_string_text
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      block = headline.block
      assert block.is_a?(Wiki::Api::PageBlock), "expected block object"
      texts = block.to_texts
      assert texts.is_a?(Array) && !texts.empty?, "expected array"
      texts.each do |text|
        assert text.is_a?(String), "expected string"
      end
    end
  end

  # test list items from page blocks
  def test_page_block_list_items
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      block = headline.block
      assert block.is_a?(Wiki::Api::PageBlock), "expected block object"
      list_items = block.list_items
      assert list_items.is_a?(Array), "expected array"
      list_items.each do |list_item|
        assert list_item.is_a?(Wiki::Api::PageListItem), "expected list item object"
      end
    end
  end

  # test links within page blocks
  def test_page_block_links
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      block = headline.block
      assert block.is_a?(Wiki::Api::PageBlock), "expected block object"
      links = block.links
      assert links.is_a?(Array), "expected array"
      links.each do |link|
        assert link.is_a?(Wiki::Api::PageLink), "expected link object"
        assert link.uri.is_a?(URI), "expected uri object"
      end
    end
  end

  # test links within list items
  def test_page_block_list_inner_links
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      block = headline.block
      assert block.is_a?(Wiki::Api::PageBlock), "expected block object"
      list_items = block.list_items
      assert list_items.is_a?(Array), "expected array"
      list_items.each do |list_item|
        assert list_item.is_a?(Wiki::Api::PageListItem), "expected list item object"
        links = list_item.links
        links.each do |link|
          assert link.is_a?(Wiki::Api::PageLink), "expected link object"
          assert link.uri.is_a?(URI), "expected uri object"
        end
      end
    end
  end

  # test single headline invocation
  def test_page_invocation_single
    page = Wiki::Api::Page.new name: @page_name
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"

    # collect headline names
    hs = []
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      hs << headline.name
    end

    # query every headline manually
    hs.each do |h|
      # test headline query
      headlines = page.headline h
      # test for at least one (many indicates multiple headlines with the same name)
      assert !headlines.empty?, "expected a list of headlines"
      assert headlines.size == 1, "expected one headline"
      headlines.each do |headline|
        assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      end
    end
  end

  def test_page_headline_search_downcase
    page = Wiki::Api::Page.new name: @page_name

    headlines = page.headline "Editing_Wiktionary"
    assert !headlines.empty?, "expected headlines"
    assert headlines.size == 1, "expected one headline"


    # iterate headlines
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
    end

    # search downcase
    headlines = page.headline "editing_wiktionary"
    assert !headlines.empty?, "expected headlines"

    # iterate headlines
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
    end

  end

  def test_page_headline_search_regular
    page = Wiki::Api::Page.new name: @page_name

    headlines = page.headline "Editing_Wiktionary"
    assert !headlines.empty?, "expected headlines"
    assert headlines.size == 1, "expected one headline"

    # iterate headlines
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
    end

    # search downcase
    headlines = page.headline "editing wiktionary"
    assert headlines.size == 1, "expected one headline"

    headlines = page.headline "editing wiktionary"
    assert headlines.size == 1, "expected one headline"

  end

end