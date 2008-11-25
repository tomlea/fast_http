Gem::Specification.new do |s|

  s.name = 'fast_http'
  s.version = '0.1'
  s.platform = Gem::Platform::RUBY

  s.summary = "The http client from rfuzz extracted into its own gem."
  
  s.description = <<-DESC.strip.gsub(/\n\s+/, " ")
  
  DESC
  
  s.author="Tom Lea"
  
  s.files += Dir.glob("ext/**/*")
  s.files += Dir.glob("lib/**/*.rb")
  
  s.require_path = 'lib'
  
  s.extensions << 'ext/http11_client/extconf.rb'
  
  s.test_suite_file = "test/test_httpparser.rb"
  
end


