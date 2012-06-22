# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ravenloft/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["George Avramidis", "Kostas Karachalios"]
  gem.email         = ["avramidg@gmail.com"]
  gem.description   = %q{D&D Information parser}
  gem.summary       = %q{Ravenloft will parse all the information available form D&D insider site. An active subscription is required.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ravenloft"
  gem.require_paths = ["lib"]
  gem.version       = Ravenloft::VERSION

	gem.add_dependency "nokogiri"
  gem.add_dependency "data_mapper"
  gem.add_dependency "dm-sqlite-adapter"

	gem.add_development_dependency "rspec"
	gem.add_development_dependency "pry"
	gem.add_development_dependency "guard-rspec"

end
