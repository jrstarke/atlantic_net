Gem::Specification.new do |spec|
  spec.name          = "atlantic_net"
  spec.version       = "0.1.1"
  spec.authors       = ["Jamie Starke"]
  spec.email         = ["git@jamiestarke.com"]
  spec.description   = "A Ruby wrapper of the Atlantic.net API"
  spec.summary       = "A Ruby wrapper of the Atlantic.net API"
  spec.homepage      = "http://github.com/jrstarke/atlantic_net"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "rspec-given"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "uuidtools"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'pry-nav'
end
