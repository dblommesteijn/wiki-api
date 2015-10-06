# Wiki::Api

Wiki API is a gem (Ruby on Rails) that interfaces with the MediaWiki API (https://www.mediawiki.org/wiki/API:Main_page). This gem is more than a interface, it has abstract classes for Page and Headline parsing. You're able to iterate through these headlines, and access data accordingly.

NOTE: This gem has a nokogiri (http://nokogiri.org/Nokogiri.html) backend (for HTML parsing). Major components: Page, Headline, Block, ListItem, and Link are wrappers for easy data access, however it's still possible to retreive the raw HTML within these objects.

Requests to the MediaWiki API use the following URI structure:

    http(s)://somemediawiki.org/w/api.php?action=parse&format=json&page="anypage"

[![Build Status](https://travis-ci.org/dblommesteijn/wiki-api.svg?branch=master)](https://travis-ci.org/dblommesteijn/wiki-api) [![Code Climate](https://codeclimate.com/github/dblommesteijn/wiki-api.png)](https://codeclimate.com/github/dblommesteijn/wiki-api) [![Dependency Status](https://gemnasium.com/dblommesteijn/wiki-api.svg)](https://gemnasium.com/dblommesteijn/wiki-api)

# RDoc (rdoc.info)

    http://rdoc.info/github/dblommesteijn/wiki-api/frames/file/README.md


### Dependencies (production)

* json
* nokogiri


### Feature Roadmap

* Version (0.1.0)

  Major current release with several core changes.

* Version (0.1.1)

  In depth headline search (recursive headline search)

  Please drop me a line (or create a pull request) for additions.


### Changelog

* Version (0.0.2) -> (current)

  PageLink URI without global config Exception resolved

  Reverse (parent) object lookup

  Nested PageHeadline objects

* Version (current) -> (0.1.1)

  Recursive headline search using headline_in_depth(name, depth).



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

### Query a Page and Headline

Requesting headlines from a given page.

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
# the root headline equals the pagename
puts page.root_headline.name
# iterate next level of headlines
page.root_headline.headlines.each do |headline_name, headline|
  # printing headline name (PageHeadline)
  puts headline.name
end
```

Getting headlines for a given name.

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
# lookup headline by name (underscore and case are ignored)
headline = page.root_headline.headline("editing wiktionary").first
# printing headline name (PageHeadline)
puts headline.name
# get the type of nested headline (html h1,2,3,4 etc.)
puts headline.type
```

### Basic Page structure

```ruby
page = Wiki::Api::Page.new name: "Wiktionary:Welcome,_newcomers"
# iterate PageHeadline objects
page.root_headline.headlines.each do |headline_name, headline|
  # exposing nokogiri internal elements
  elements = headline.elements.flatten
  elements.each do |element|
    # print will result in: Nokogiri::XML::Text or Nokogiri::XML::Element
    puts element.class
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


### Example using Global config (https://en.wikipedia.org/wiki/Ruby_on_Rails)

This is a example of querying wikipedia.org on the page: "Ruby_on_rails", and printing the References headline links for each list item.

```ruby
# setting a target config
CONFIG = { uri: "https://en.wikipedia.org" }
Wiki::Api::Connect.config = CONFIG

# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_Rails"

# get headlines with name Reference (there can be multiple headlines with the same name!)
headlines = page.root_headline.headline "References"

# iterate headlines
headlines.each do |headline|
  # iterate list items on the given headline
  headline.block.list_items.each do |list_item|
    # print the uri of all links
    puts list_item.links.map{ |l| l.uri }
  end
end
```


### Example passing URI (https://en.wikipedia.org/wiki/Ruby_on_Rails)

This is the same example as the one above, except for setting a global config to direct the requests to a given URI.

```ruby
# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_Rails", uri: "https://en.wikipedia.org"

# get headlines with name Reference (there can be multiple headlines with the same name!)
headlines = page.root_headline.headline "References"

# iterate headlines
headlines.each do |headline|
  # iterate list items on the given headline
  headline.block.list_items.each do |list_item|

    # print the uri of all links
    puts list_item.links.map{ |l| l.uri }

  end
end
```


### Example searching headlines

This example shows how the headlines can be searched. For more info check: https://github.com/dblommesteijn/wiki-api/blob/master/lib/wiki/api/page.rb#L97


```ruby
# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_Rails", uri: "https://en.wikipedia.org"

# NOTE: the following are all valid headline names:
# request headline (by literal name)
headlines = page.root_headline.headline "Philosophy_and_design"
puts headlines.map{|h| h.name}
# request headline (by downcase name)
headlines = page.root_headline.headline "philosophy_and_design"
puts headlines.map{|h| h.name}
# request headline (by human name)
headlines = page.root_headline.headline "philosophy and design"
puts headlines.map{|h| h.name}

# NOTE2: headlines are matched on headline.start_with?(requested_headline)
# because of start_with? compare this should work as well!
headlines = page.root_headline.headline "philosophy"
puts headlines.map{|h| h.name}
```


### Example searching headlines in depth

Recursive search on all nested headlines, including in depth searches.

```ruby
# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_Rails", uri: "https://en.wikipedia.org"
# get root
root_headline = page.root_headline
# lookup 'ramework structure' on current level
headline = root_headline.headline_in_depth("framework structure").first
puts headline.name
# NOTE: lookup of nested headlines does not work with the headline function (because 'Framework_structure' is nested within 'Technical_overview')
headline = root_headline.headline("framework structure").first
# depth can be limited adding the depth parameter
# NOTE: the example below will return nil, 'Framework_structure' is nested beyond depth = 0!
depth = 0
headline = root_headline.headline_in_depth("framework structure", depth).first
```




