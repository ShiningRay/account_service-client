lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'account_service/client/version'

Gem::Specification.new do |spec|
  spec.name = 'account_service-client'
  spec.version = BitRabbit::AccountService::Client::VERSION
  spec.authors = ['ShiningRay']
  spec.email = ['tsowly@hotmail.com']

  spec.summary = 'Client for Bitrabbit Account Service'
  spec.description = 'Client for Bitrabbit Account Service'
  spec.homepage = 'https://bitrabbit.com'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'typhoeus', '~> 1.3.1'
  spec.add_dependency 'activesupport', '>= 5.2.0'
  spec.add_dependency 'tzinfo', '~> 1.2.0'
  spec.add_dependency 'oauth2', '~> 1.1'
  spec.add_dependency 'json_api_client', '~> 1.17.0'
  spec.add_dependency 'jwt', '>= 2.1.0'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.12.2'
end
