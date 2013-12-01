Gem::Specification.new do |s|
  s.name = 'gliffy'
  s.version = '0.0.10'
  s.date = '2013-12-01'
  s.summary = 'Gliffy API client'
  s.description = 'A simple Gliffy REST API wrapper.'
  s.license = 'MIT'
  s.authors = ["Konstantin Burnaev"]
  s.email = 'kbourn@gmail.com'
  s.files = Dir[
    "{lib,spec}/**/*",
    "README*",
    "LICENSE*"
  ]
  s.executables = ["gliffy-cli"]
  s.homepage = "https://github.com/bkon/gliffy"

  s.add_dependency('oauth')
  s.add_dependency('nokogiri')
  s.add_dependency('gli')

  s.add_development_dependency('rspec', '>= 2.14')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('http_logger')
  s.add_development_dependency('guard')
  s.add_development_dependency('rb-readline')
  s.add_development_dependency('guard-rspec')
  s.add_development_dependency('ci_reporter')
  s.add_development_dependency('rake')
end
