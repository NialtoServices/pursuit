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
  spec.homepage      = 'https://github.com/nialtoservices/pursuit'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['yard.run'] = 'yri'

  spec.add_runtime_dependency 'activerecord',  '>= 5.2.0', '< 7.1.0'
  spec.add_runtime_dependency 'activesupport', '>= 5.2.0', '< 7.1.0'

  spec.add_development_dependency 'bundler',       '~> 2.0'
  spec.add_development_dependency 'combustion',    '~> 1.3'
  spec.add_development_dependency 'guard',         '~> 2.18'
  spec.add_development_dependency 'guard-rspec',   '~> 4.7'
  spec.add_development_dependency 'pry',           '~> 0.14'
  spec.add_development_dependency 'rake',          '~> 13.0'
  spec.add_development_dependency 'rspec',         '~> 3.12'
  spec.add_development_dependency 'rspec-rails',   '~> 6.0'
  spec.add_development_dependency 'rubocop',       '~> 1.44'
  spec.add_development_dependency 'rubocop-rake',  '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.18'
  spec.add_development_dependency 'sqlite3',       '~> 1.6'
  spec.add_development_dependency 'yard',          '~> 0.9'
end
