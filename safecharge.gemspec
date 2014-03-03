# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safecharge/version'

Gem::Specification.new do |spec|
  spec.name          = "safecharge"
  spec.version       = Safecharge::VERSION
  spec.authors       = ["Dave Sag", "Roger Huang", "Roger Huang", "André Allavena"]
  spec.email         = ["davesag@gmail.com", "roger.huang@excite.com", "roger@igecorporate.com", "andre@igecorporate.com"]
  spec.description   = "Implements all of the features of the SafeCharge API."
  spec.summary       = "A Ruby Wrapper for the SafeCharge API"
  spec.homepage      = "http://cv.davesag.com/"
  spec.license       = "MIT"
  spec.date          = Time.now.utc.strftime("%Y-%m-%d")

  spec.files         = `git ls-files`.split($/) - %w(.rspec .gitignore Rakefile) - `git ls-files test_data`.split($/) - `git ls-files spec`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "dotenv", "~> 0.10"
end
