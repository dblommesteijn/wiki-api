# encoding: utf-8

require 'rubygems'
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/../../lib/wiki/api")

#
# Testing the parsing of URI by passing a uri variable to Page:
#   https://en.wiktionary.org/wiki/Wiktionary:Welcome,_newcomers
#

class WikiPageInlineConfig < Test::Unit::TestCase

  def setup
    # NOTE: comment Page.config, to use the online MediaWiki instance
    # Wiki::Api::Page.config = PAGE_CONFIG
    # Wiki::Api::Connect.config = GLB_CONFIG
    # @page_name = "Wiktionary:Welcome,_newcomers"
  end

  def teardown
  end

  # test simple page invocation
  def test_page_invocation_with_uri
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers", uri: "http://en.wiktionary.org"
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"
    assert headlines.size > 1, "expected more than one headline"
    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
    end
  end

  def test_wrong_page_invocation_with_uri
    begin
      page = Wiki::Api::Page.new name: "A_Wrong_Page_Name", uri: "http://en.wiktionary.org"
      assert false, "expected a failiure"
    rescue Exception => e
      assert true, "expected a failiure"
    end
  end

  def test_page_link_uri_without_config_global
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers", uri: "http://en.wiktionary.org"
    headlines = page.headlines
    assert !headlines.empty?, "expected headlines"

    headlines.each do |headline|
      assert headline.is_a?(Wiki::Api::PageHeadline), "expected headline object"
      block = headline.block
      assert block.is_a?(Wiki::Api::PageBlock), "expected block object"
      list_items = block.list_items

      list_items.each do |list_item|
        assert list_item.is_a?(Wiki::Api::PageListItem), "expected list item object"
        links = list_item.links
        links.each do |link|
          assert link.is_a?(Wiki::Api::PageLink), "expected link object"
          assert link.uri.is_a?(URI), "expected uri object"
          assert link.uri.to_s.start_with?("http://en.wiktionary.org"), "leading uri not found"
        end
      end

    end
  end

end

