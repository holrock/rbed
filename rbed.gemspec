# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbed/version'

Gem::Specification.new do |spec|
  spec.name          = "rbed"
  spec.version       = Rbed::VERSION
  spec.authors       = ["holrock"]
  spec.email         = ["ispeporez@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = "plink bed reader for ruby"
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "GPL3"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/rbed/extconf.rb"]

  spec.add_development_dependency "bundler", ">= 2.2.33"
  spec.add_development_dependency "rake", ">= 12.3.2"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "minitest"
end
