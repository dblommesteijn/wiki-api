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
      texts = {}
      # iterate headlines
      page.blocks.each do |headline, element_groups|
        element_groups.each_with_index do |element_group, i|
          element_group.each do |element|
            # parse elements to text
            text = Wiki::Api::Util.element_to_text element if element.is_a? Nokogiri::XML::Element
            next if text.nil? || text.empty?
            texts[headline] ||= []
            texts[headline] << text
          end
        end
      end
      self.assert_texts texts
    else
      assert false, "expected some headlines"
    end
  end

  def test_page_single_block
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"

    headline = "Editing_Wiktionary"
    texts = {}
    elements = page.headline_block headline
    elements.each do |element|
      text = Wiki::Api::Util.element_to_text element if element.is_a? Nokogiri::XML::Element
      next if text.nil? || text.empty?
      texts[headline] ||= []
      texts[headline] << text
    end
    self.assert_texts texts
  end

  def test_page_first_part
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"

    headline = "Wiktionary:Welcome,_newcomers"
    texts = {}
    elements = page.headline_block headline
    elements.each do |element|
      text = Wiki::Api::Util.element_to_text element if element.is_a? Nokogiri::XML::Element
      next if text.nil? || text.empty?
      texts[headline] ||= []
      texts[headline] << text
    end
    self.assert_texts texts
  end


  def test_page_blocks_buildin
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
    texts = page.blocks_to_text
    assert texts.is_a?(Hash), "expected a hash"
    self.assert_texts texts
  end

  def test_page_single_block_buildin
    page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
    texts = page.blocks_headline_to_text "Wiktionary:Welcome,_newcomers"
    assert texts.is_a?(Hash), "expected a hash"
    self.assert_texts texts
  end


  protected

  def assert_texts texts

    if texts.include? "Wiktionary:Welcome,_newcomers"
      assert texts["Wiktionary:Welcome,_newcomers"][0] == "Hello, and welcome! Wiktionary is a multilingual free dictionary, being written collaboratively on this website by people from around the world. Entries may be edited by anyone!"
      assert texts["Wiktionary:Welcome,_newcomers"][1] == "Designed as the lexical companion to Wikipedia, the encyclopedia project, Wiktionary has grown beyond a standard dictionary and now includes a thesaurus, a rhyme guide, phrase books, language statistics and extensive appendices. We aim to include not only the definition of a word, but also enough information to really understand it. Thus etymologies, pronunciations, sample quotations, synonyms, antonyms and translations are included."
      assert texts["Wiktionary:Welcome,_newcomers"][2] == "Wiktionary is a wiki, which means that you can edit it, and all the content is dual-licensed under both the Creative Commons Attribution-ShareAlike 3.0 Unported License as well as the GNU Free Documentation License. Before you contribute, you may wish to read through some of our Help pages, and bear in mind that we do things quite differently from other wikis. In particular, we have strict layout conventions and inclusion criteria. Learn how to start a page, how to edit entries, experiment in the sandbox and visit our Community Portal to see how you can participate in the development of Wiktionary."
      assert texts["Wiktionary:Welcome,_newcomers"][3] == "We have created 3,311,698 articles since starting in December, 2002, and we’re growing rapidly."
    end

    if texts.include? "Editing_Wiktionary"
      assert texts["Editing_Wiktionary"][0] == "People like yourself are very active in building this project. While you are reading this, it is likely someone is editing one of our entries. Many knowledgeable people are already at work, but everybody is welcome!"
      assert texts["Editing_Wiktionary"][1] == "Contributing does not require logging in, but we would prefer that you do, as it facilitates the administration of this site.(Note that logging in also prevents the IP address of your computer from being displayed in the page history.)"
      assert texts["Editing_Wiktionary"][2] == "You can dive in right now and add or alter a definition, add example sentences, or help us to properly format or categorize entries. You can even create a page for a term we’re missing. Please feel free to be bold in editing pages!"
      assert texts["Editing_Wiktionary"][3] == "How could allowing everyone to edit produce a high‐quality product instead of total disorder? Because most people want to help, and keeping it open to everyone creates the potential for making many good and ever-improving entries. Records are kept of all changes, so even unhelpful edits can easily be reverted by other users. To use a now‐famous catchphrase, in essence:“Given enough eyeballs, all errors are shallow.”"
      assert texts["Editing_Wiktionary"][4] == "To start out, users might want to use the‘ Recent changes’ or‘ Random page’ link(found in the navigation box elsewhere on this page), to get an idea of the kinds of pages you can find here.(It might be surprising how many non-English words are entered here!)"
    end

    if texts.include? "Norms_and_etiquette" 
      assert texts["Norms_and_etiquette"][0] == "See also Help:Interacting with humans"
      assert texts["Norms_and_etiquette"][1] == "One important thing you should know is that we have borrowed from our sister project Wikipedia some cultural norms you should respect:"
      assert texts["Norms_and_etiquette"][2] == "We try not to argue pointlessly. This isn’t a debate forum. After civilized and reasonable discussion, we try to reach broad consensus in order to present an accurate, neutral summary of all relevant facts for future readers. We try to make the entries as unbiased as we can, meaning that definitions or descriptions— even of controversial topics— are not meant to be platforms for preaching of any kind. Bear in mind this is a dictionary, which means there are many things it is not. At any point, if you are uncomfortable changing someone else’s work, and you want to add a thought(or question or comment) about an entry or other page, the place is its talk page(click on the\"discussion\" tab at the top or the\"Discuss this page\" link in the sidebar or elsewhere, depending on your preference skin). Note, though, that we try to keep discussion focused on improving this dictionary."
      assert texts["Norms_and_etiquette"][3] == "However, there are also some differences between Wikipedia and Wiktionary. If you already have some experience with editing Wikipedia, then you may find our guide to Wikipedia users useful as a quick introduction."
    end

    if texts.include? "For_more_information" 
      assert texts["For_more_information"][0] == "More introductory information and descriptions of community norms are on the following pages:"
      assert texts["For_more_information"][1] == "How to start a page How to edit a page Staying cool when editing gets hot Wiktionary FAQ Wiktionary for Wikipedians"
      assert texts["For_more_information"][2] == "For more policy and style guidelines or guidance, see our Community Portal or Help:Contents."
    end
  end


end
