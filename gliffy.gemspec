Gem::Specification.new do |s|
  s.name = 'gliffy'
  s.version = '0.0.5'
  s.date = '2013-01-01'
  s.summary = 'Gliffy API client'
  s.description = 'A simple Gliffy REST API wrapper.'
  s.authors = ["Konstantin Burnaev"]
  s.email = 'bkon@bkon.ru'
  s.files = ["lib/gliffy.rb"]

  s.add_dependency('oauth')
  s.add_dependency('nokogiri')

  s.add_development_dependency('rspec', '>= 2.14')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('http_logger')
  s.add_development_dependency('guard')
  s.add_development_dependency('guard-rspec')
end
