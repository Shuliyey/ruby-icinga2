
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icinga2/version'

Gem::Specification.new do |s|
  s.name        = 'icinga2'
  s.version     = Icinga2::VERSION
  s.date        = '2017-06-10'
  s.summary     = 'Icinga2 API'
  s.description = 'Ruby Class for the Icinga2 API'
  s.authors     = ['Bodo Schulz']
  s.email       = 'bodo@boone-schulz.de'

  s.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'doc/*',
    'examples/*.rb'
  ]

  s.homepage    = 'https://github.com/bodsch/ruby-icinga2'
  s.license     = 'LGPL-2.1+'

  s.add_dependency('rest-client', '~> 2.0')
  s.add_dependency('openssl', '~> 2.0')
  s.add_dependency('json', '~> 2.1')


  s.add_development_dependency( "rspec" )
  s.add_development_dependency( "rspec-nc" )
  s.add_development_dependency( "guard" )
  s.add_development_dependency( "guard-rspec" )
  s.add_development_dependency( "pry" )
  s.add_development_dependency( "pry-remote" )
  s.add_development_dependency( "pry-nav" )

end
