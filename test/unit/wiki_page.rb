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
    page = Wiki::Api::Page.new name: "developer"
  end

  def test_page_headers
    page = Wiki::Api::Page.new name: "developer"
    puts page.headers.inspect


  end

end
