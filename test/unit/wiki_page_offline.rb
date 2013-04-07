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

    # load page
    page = Wiki::Api::Page.new name: "program"
    assert page.is_a?(Wiki::Api::Page), "expected Page object"
    headline = page.root_headline
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


  def test_headlines_search_tree
    page = Wiki::Api::Page.new name: "program"
    assert page.is_a?(Wiki::Api::Page), "expected Page object"

    # get root headline
    headline = page.root_headline
    assert headline.is_a?(Wiki::Api::PageHeadline), "expected PageHeadline object"
    assert headline.name == "program", "expected program headline"

    # search in depth on headline noun
    nouns = headline.headline_by_name "noun", 1

    nouns.each do |noun|
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
  end


  def test_headlines_verify_tree
    page = Wiki::Api::Page.new name: "program"
    headline = page.root_headline
    # get root
    assert headline.name == "program", "expected program name"
    
    # iterate one deep and verify headline index names
    headline.headlines.each do |name, headline|
      assert headline.name == name
    end
    headlines = headline.headlines.values

    # English
    english_headlines = headlines[0]
    assert english_headlines.name == "English"
    english_headlines = english_headlines.headlines.values
    assert english_headlines[0].name == "Alternative_forms"
    assert english_headlines[1].name == "Etymology"
    assert english_headlines[2].name == "Pronunciation"
    assert english_headlines[3].name == "Noun"
    noun_english_headlines = english_headlines[3].headlines.values
    assert noun_english_headlines[0].name == "Usage_notes"
    assert noun_english_headlines[1].name == "Synonyms"
    assert noun_english_headlines[2].name == "Translations"
    assert english_headlines[4].name == "Verb"
    verb_english_headlines = english_headlines[4].headlines.values
    assert verb_english_headlines[0].name == "Related_terms"
    assert verb_english_headlines[1].name == "Translations_2"
    assert english_headlines[5].name == "External_links"

    # Czech
    czech_headlines = headlines[1]
    assert czech_headlines.name == "Czech"
    czech_headlines = czech_headlines.headlines.values
    assert czech_headlines[0].name == "Pronunciation_2"
    assert czech_headlines[1].name == "Noun_2"

    # Hungarian
    hungarian_headlines = headlines[2]
    assert hungarian_headlines.name == "Hungarian"
    hungarian_headlines = hungarian_headlines.headlines.values
    assert hungarian_headlines[0].name == "Pronunciation_3"
    assert hungarian_headlines[1].name == "Noun_3"
    noun_hungarian_headlines = hungarian_headlines[1].headlines.values
    assert noun_hungarian_headlines[0].name == "Declension"
    assert noun_hungarian_headlines[1].name == "Derived_terms"

    # Norwegian
    norwegian_headlines = headlines[3]
    assert norwegian_headlines.name == "Norwegian_Bokm.C3.A5l"
    norwegian_headlines = norwegian_headlines.headlines.values
    assert norwegian_headlines[0].name == "Noun_4"

    # Romanian
    romanian_headlines = headlines[4]
    assert romanian_headlines.name == "Romanian"
    romanian_headlines = romanian_headlines.headlines.values
    assert romanian_headlines[0].name == "Etymology_2"
    assert romanian_headlines[1].name == "Noun_5"
    noun_romanian_headlines = romanian_headlines[1].headlines.values
    assert noun_romanian_headlines[0].name == "Declension_2"
    assert noun_romanian_headlines[1].name == "Related_terms_2"

    # Serbo-Croatian
    serb_croatian_headlines = headlines[5]
    assert serb_croatian_headlines.name == "Serbo-Croatian"
    serb_croatian_headlines = serb_croatian_headlines.headlines.values
    assert serb_croatian_headlines[0].name == "Noun_6"
    noun_serb_croatian_headlines = serb_croatian_headlines[0].headlines.values
    assert noun_serb_croatian_headlines[0].name == "Declension_3"

    # Slovak
    slovak_headlines = headlines[6]
    assert slovak_headlines.name == "Slovak"
    slovak_headlines = slovak_headlines.headlines.values
    assert slovak_headlines[0].name == "Noun_7"

    # Swedish
    swedish_headlines = headlines[7]
    assert swedish_headlines.name == "Swedish"
    swedish_headlines = swedish_headlines.headlines.values
    assert swedish_headlines[0].name == "Etymology_3"
    assert swedish_headlines[1].name == "Noun_8"
    noun_swedish_headlines = swedish_headlines[1].headlines.values
    assert noun_swedish_headlines[0].name == "Declension_4"

    # Turkish
    turkish_headlines = headlines[8]
    assert turkish_headlines.name == "Turkish"
    turkish_headlines = turkish_headlines.headlines.values
    assert turkish_headlines[0].name == "Etymology_4"
    assert turkish_headlines[1].name == "Noun_9"
    noun_turkish_headlines = turkish_headlines[1].headlines.values
    assert noun_turkish_headlines[0].name == "Declension_5"

  end

end