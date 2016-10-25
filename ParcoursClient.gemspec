# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ParcoursClient/version'

Gem::Specification.new do |spec|
  spec.name          = "ParcoursClient"
  spec.version       = ParcoursClient::VERSION
  spec.authors       = ["ParcoursClient"]
  spec.email         = ["denis.peyrusaube@retengr.com"]

  spec.summary       = "Analyse de logs"
  spec.description   = "ParcoursClient est un gem permettant d'analyser un fichier de log respectant le format common log"
  spec.homepage      = "https://www.retengr.com"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://localhost:9292/"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
