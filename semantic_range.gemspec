lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'semantic_range/version'

Gem::Specification.new do |spec|
  spec.name          = 'semantic_range'
  spec.version       = SemanticRange::VERSION
  spec.authors       = ['Andrew Nesbitt']
  spec.email         = ['andrewnez@gmail.com']

  spec.summary       = 'node-semver rewritten in ruby, for comparison and inclusion of semantic versions and ranges'
  spec.homepage      = 'https://libraries.io/github/librariesio/semantic_range'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*'] + ['README.md', 'LICENSE.txt']
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['rubygems_mfa_required'] = 'true'
  end

  spec.add_development_dependency 'rspec', '~> 3.4'
end
