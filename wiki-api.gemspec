# frozen_string_literal: true

require 'English'
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wiki/api/version'

Gem::Specification.new do |spec|
  spec.name          = 'wiki-api'
  spec.version       = Wiki::Api::VERSION
  spec.authors       = ['Dennis Blommesteijn']
  spec.email         = ['dennis@blommesteijn.com']
  spec.description   = 'MediaWiki API and Page content parser for Headlines (nested), TextBlocks, ListItems, and Links.'
  spec.summary       = 'MediaWiki API and Page content parser for Headlines (nested), TextBlocks, ListItems, and Links.'
  spec.homepage      = 'https://github.com/dblommesteijn/wiki-api'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency('bundler', '> 1.3')
  spec.add_development_dependency('pry', '~> 0.14')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '~> 1.59.0')
  spec.add_development_dependency('test-unit', '> 2.0.0')

  # dependencies
  spec.add_dependency('nokogiri', '> 1.13.0')
end
