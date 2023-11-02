# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pursuit/constants'

Gem::Specification.new do |spec|
  spec.name          = 'pursuit'
  spec.version       = Pursuit::VERSION
  spec.authors       = ['Nialto Services']
  spec.email         = ['support@nialtoservices.co.uk']

  spec.summary       = 'Advanced key-based searching for ActiveRecord objects.'
  spec.homepage      = 'https://github.com/NialtoServices/pursuit'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['yard.run'] = 'yri'

  spec.add_runtime_dependency 'activerecord',  '>= 5.2.0', '<= 8.0.0'
  spec.add_runtime_dependency 'activesupport', '>= 5.2.0', '<= 8.0.0'
  spec.add_runtime_dependency 'parslet',       '~> 2.0'
end
