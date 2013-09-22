require 'rspec'
require 'nokogiri'

require 'simplecov'
SimpleCov.command_name "test:units"
SimpleCov.start do 
    add_filter '/spec/'
    add_filter '/lib/gliffy/oauth/'
    coverage_dir '/reports/coverage'
end

require 'gliffy'

def fixture(filename, substitutions = {})
    Nokogiri::XML(
        fixture_xml(filename, substitutions)
    )
end

def fixture_xml(filename, substitutions = {})
    raw_document = IO.read(
        File.join(
            File.dirname(__FILE__), 
            "fixtures",
            "#{filename}.xml"
        ) 
    )

    raw_document % substitutions
end

RSpec.configure do |config|
    config.expect_with :rspec do |c|
        c.syntax = :expect
    end
end
