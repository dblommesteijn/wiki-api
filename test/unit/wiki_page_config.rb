# encoding: utf-8

require 'rubygems'
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/../../lib/wiki/api")

#
# Testing the parsing of URI by passing a uri variable to Page:
#   https://en.wiktionary.org/wiki/Wiktionary:Welcome,_newcomers
#

class WikiPageConfig < Test::Unit::TestCase

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
    assert headlines.size < 1, "expected more than one headline"
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

end

