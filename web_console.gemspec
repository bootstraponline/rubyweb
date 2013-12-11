# encoding: utf-8
def self.add_to_path path
 path = File.expand_path "../#{path}/", __FILE__

 $:.unshift path unless $:.include? path
end

add_to_path 'lib'

require 'web_console/version'

Gem::Specification.new do |s|
  # 1.8.x is not supported
  s.required_ruby_version = '>= 1.9.3'

  s.name = 'web_console'
  s.version = Appium::Console::VERSION
  s.date = Appium::Console::DATE
  s.license = 'http://www.apache.org/licenses/LICENSE-2.0.txt'
  s.description = s.summary = 'Appium Ruby Console'
  s.description += '.' # avoid identical warning
  s.authors = s.email = [ 'code@bootstraponline.com' ]
  s.homepage = 'https://github.com/bootstraponline/web_console'
  s.require_paths = [ 'lib' ]

  s.add_runtime_dependency 'page-object', '~> 0.9.4'
  s.add_runtime_dependency 'pry', '= 0.9.12.4'
  s.add_runtime_dependency 'spec', '~> 5.0.19'
  s.add_development_dependency 'rake', '~> 10.1.0'
  s.add_development_dependency 'posix/spawn', '~> 0.3.6'

  s.executables   = [ 'rubyweb' ]
  s.files = `git ls-files`.split "\n"
end