# Wiki::Api

Wiki API is a gem (Ruby on Rails) that interfaces with the MediaWiki API (https://www.mediawiki.org/wiki/API:Main_page). This gem is more than a interface, it has abstract classes like: Page on which you can request page parameters (like headlines, and text blocks within headlines).

NOTE: nokogiri is used for background parsing of HTML. Because I believe there is no point of wrapping internals (composing) for this purpose, nokogiri nodes elements etc. are exposed (http://nokogiri.org/Nokogiri.html) through the wiki-api.

Requests to the MediaWiki API use the following URI structure:

    http(s)://somemediawiki.org/w/api.php?action=parse&format=json&page="anypage"


### Dependencies (production)

* json
* nokogiri


### Roadmap

* Version (0.0.1) (current)

  Initial project.

* Version (0.0.2)

  Buildin to_text options for blocks

  Auto parsing lists (ul, ol, with li's)

  Auto parsing links (a href)


### Known Issues

None discovered thus far.


## Installation

Add this line to your application's Gemfile (bundler):

    gem 'wiki-api', git: "git://github.com/dblommesteijn/wiki-api.git"

And then execute:

    $ bundle

Or install it yourself (RubyGems):

    $ gem install wiki-api


## Setup

Define a configuration for your connection (initialize script), this example uses wiktionary.org.
NOTE: it can connect to both HTTP and HTTPS MediaWikis.

```ruby
CONFIG = { uri: "http://en.wiktionary.org" }
```

Setup default configuration (initialize script)

```ruby
Wiki::Api::Connect.config = CONFIG
```


## Usage (Page abstract)

You can use the Page abstract to request information from your connected wiki.

### Request all page blocks

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
page.blocks.each do |headline, element_groups|
  element_groups.each do |element_group|
    element_group.each do |element|
      # exposed nokogiri element
      text = Wiki::Api::Util.element_to_text element if element.is_a? Nokogiri::XML::Element
      puts text
    end
  end
end
```

Or auto parse it with a buildin function
Note: no exposure of nokogiri here!

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
texts = page.blocks_to_text
texts.each do |headline, texts|
  texts.each do |text|
    # this will print the text
    puts text
  end
end
```


### Request all blocks for a predefined headline

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
# headline_name is a lookup of the headline element Id
# <span class="mw-headline" id="Editing_Wiktionary">Editing Wiktionary</span>
elements = page.headline_block "Editing_Wiktionary"
elements.each do |element|
  # exposed nokogiri element
  text = Wiki::Api::Util.element_to_text element if element.is_a? Nokogiri::XML::Element
  puts text
end
```

Or auto parse it with a buildin function
Note: no exposure of nokogiri here!

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
texts = page.blocks_headline_to_text "Editing_Wiktionary"
texts.each do |headline, texts|
  texts.each do |text|
    # this will print the text
    puts text
  end
end
```




