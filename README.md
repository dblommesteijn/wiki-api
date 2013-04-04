# Wiki::Api

Wiki API is a gem (Ruby on Rails) that interfaces with the MediaWiki API (https://www.mediawiki.org/wiki/API:Main_page). This gem is more than a interface, it has abstract classes like: Page on which you can request page parameters (like headlines, and text blocks within headlines).

NOTE: nokogiri is used for background parsing of HTML. Because I believe there is no point of wrapping internals (composing) for this purpose, nokogiri nodes elements etc. are exposed (http://nokogiri.org/Nokogiri.html) through the wiki-api.

Requests to the MediaWiki API use the following URI structure:

    http(s)://somemediawiki.org/w/api.php?action=parse&format=json&page="anypage"

# RDoc (rdoc.info)

    http://rdoc.info/github/dblommesteijn/wiki-api/


### Dependencies (production)

* json
* nokogiri


### Feature Roadmap

* Version (0.0.3)
  
  No features determined yet (please drop me a line if you're interested in additions).


### Changelog

* Version (0.0.1) -> (current)
  
  Nested ListItems, Links (within Page)

  Search on Page headline (ignore case, and underscore)

* Version (current) -> (0.0.3)

  PageLink URI without global config Exception resolved

  Reverse (parent) object lookup



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


### Example using Global config (https://en.wikipedia.org/wiki/Ruby_on_rails)

This is a example of querying wikipedia.org on the page: "Ruby_on_rails", and printing the References headline links for each list item.

```ruby
# setting a target config
CONFIG = { uri: "https://en.wikipedia.org" }
Wiki::Api::Connect.config = CONFIG

# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_Rails"

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



### Example passing URI (https://en.wikipedia.org/wiki/Ruby_on_rails)

This is the same example as the one above, except for setting a global config to direct the requests to a given URI.

```ruby
# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_Rails", uri: "https://en.wikipedia.org"

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


### Example searching headlines

This example shows how the headlines can be searched. For more info check: https://github.com/dblommesteijn/wiki-api/blob/master/lib/wiki/api/page.rb#L109


```ruby
# querying the page
page = Wiki::Api::Page.new name: "Ruby_on_Rails", uri: "https://en.wikipedia.org"

# NOTE: the following are all valid headline names:

# request headline (by literal name)
headlines = page.headline "Philosophy_and_design"
puts headlines.map{|h| h.name}

# request headline (by downcase name)
headlines = page.headline "philosophy_and_design"
puts headlines.map{|h| h.name}

# request headline (by human name)
headlines = page.headline "philosophy and design"
puts headlines.map{|h| h.name}

# NOTE2: headlines are matched on headline.start_with?(requested_headline)

# because of start_with? compare this should work as well!
headlines = page.headline "philosophy"
puts headlines.map{|h| h.name}

```




