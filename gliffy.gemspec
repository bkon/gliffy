Gem::Specification.new do |s|
  s.name = 'gliffy'
  s.version = '0.0.7'
  s.date = '2013-10-05'
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
  s.homepage = "https://github.com/bkon/gliffy"

  s.add_dependency('oauth')
  s.add_dependency('nokogiri')

  s.add_development_dependency('rspec', '>= 2.14')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('http_logger')
  s.add_development_dependency('guard')
  s.add_development_dependency('guard-rspec')
  s.add_development_dependency('ci_reporter')
end
