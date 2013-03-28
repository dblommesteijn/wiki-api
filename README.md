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

  Index important words per block, page, list item;

  Parse objects for more elements within a Page.



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


## Usage

### Query a Page

Requesting headlines from a given page.

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
page.headlines.each do |headline|
  # printing headline name (PageHeadline)
  puts headline.name
end
```

Getting headlines for a given name.

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
page.headline("Wiktionary:Welcome,_newcomers").each do |headline|
  # printing headline name (PageHeadline)
  puts headline.name
end
```

### Basic Page structure

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"

# iterate PageHeadline objects
page.headlines.each do |headline|

  # exposing nokogiri internal elements
  elements = headline.elements.flatten
  elements.each do |element|
    # access Nokogiri::XML::*
  end

  # string representation of all nested text
  block.to_texts

  # iterate PageListItem objects
  block.list_items.each do |list_item|
    # string representation of nested text
    list_item.to_text
    # iterate PageLink objects
    list_item.links.each do |link|
      # check part: 'iterate PageLink objects'
    end
  end

  # iterate PageLink objects
  headline.block.links.each do |link|
    # absolute URI object
    link.uri
    # html link
    link.html
    # link name
    link.title
    # string representation of nested text
    link.to_text
  end

end
```


### Example (https://en.wikipedia.org/wiki/Ruby_on_rails)

This is a example of querying wikipedia.org on the page: "Ruby_on_rails", and printing the References headline links for each list item.

```ruby
# setting a target config
CONFIG = { uri: "https://en.wikipedia.org" }
Wiki::Api::Connect.config = CONFIG

# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_rails"

# get headlines with name Reference (there can be multiple headlines with the same name!)
headlines = page.headline "References"

# iterate headlines
headlines.each do |headline|
  # iterate list items on the given headline
  headline.block.list_items.each do |list_item|

    # print the uri of all links
    puts list_item.links.map{ |l| l.uri }
    
  end
end
```






