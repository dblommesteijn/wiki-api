# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wiki/api/version'

Gem::Specification.new do |spec|
  spec.name          = "wiki-api"
  spec.version       = Wiki::Api::VERSION
  spec.authors       = ["Dennis Blommesteijn"]
  spec.email         = ["dennis@blommesteijn.com"]
  spec.description   = %q{MediaWiki API and Page content parser for Headlines (nested), TextBlocks, ListItems, and Links.}
  spec.summary       = %q{MediaWiki API and Page content parser for Headlines (nested), TextBlocks, ListItems, and Links.}
  spec.homepage      = "https://github.com/dblommesteijn/wiki-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.3"
  spec.add_development_dependency "rake"

  # dependencies
  spec.add_dependency 'nokogiri', "~> 1.13.0"
  spec.add_dependency 'json', "> 1.6.1"
  spec.add_development_dependency "test-unit", "> 2.0.0"

end
