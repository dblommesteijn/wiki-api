require 'test_helper'

#
# Testing the connection to https://www.mediawiki.org/wiki/API:Main_page
#

class WikiConnect < Test::Unit::TestCase

  CONFIG = { uri: "http://en.wiktionary.org" }

  def setup
    Wiki::Api::Connect.config = CONFIG
  end

  def teardown
  end

  def test_connection_wiktionary
    c = Wiki::Api::Connect.new uri: "http://en.wiktionary.org"
    ret = c.connect
    assert ret.is_a?(Net::HTTPOK), "invalid response http"
  end

  def test_connection_https_wiktionary
    c = Wiki::Api::Connect.new uri: "https://en.wiktionary.org"
    ret = c.connect
    assert ret.is_a?(Net::HTTPOK), "invalid response https"
  end

  def test_page_get
    begin
      c = Wiki::Api::Connect.new
      c.page "Wiktionary:Welcome,_newcomers"
    rescue Exception => e
      assert false, "expected valid page #{e.message}"
    end
  end

  def test_page_get_non_exist
    begin
      c = Wiki::Api::Connect.new
      response = c.page "asfsldkfjjlkanv98yhok"
    rescue Exception => e
      assert (e.message == "missingtitle"), "expected invalid page #{e.message}"
    end
  end


end
