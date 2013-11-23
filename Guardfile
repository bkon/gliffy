# A sample Guardfile
# More info at https://github.com/guard/guard#readme
guard :rspec,
    :cmd => "rspec --color",
    :keep_failed => false do

    watch('spec/spec_helper.rb') { "spec" }
    watch(%r{spec/fixtures/.+\.xml}) { "spec" }
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^spec/support/*\.rb$}) { "spec" }
    watch(%r{^lib/(.+)\.rb}) { |m| "spec/lib/#{m[1]}_spec.rb" }
end
