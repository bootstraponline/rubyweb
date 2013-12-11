# encoding: utf-8
require 'rubygems'
Gem::Specification.class_eval { def self.warn( args ); end }
require 'pry'
require 'awesome_print'

module Appium; end unless defined? Appium

def define_reload paths
  Pry.send(:define_singleton_method, :_reload) do
    paths.each do |p|
      # If a page obj is deleted then load will error.
      begin
        load p
      rescue # LoadError: cannot load such file
      end
    end
  end
  nil
end

module Appium::Console
  AwesomePrint.pry!
  pwd = Dir.pwd
  to_require = pwd + '/appium.txt'

  start = File.expand_path '../start.rb', __FILE__
  cmd = ['-r', start]

  if File.exists?(to_require)
    to_require = File.read(to_require).split("\n").map do |line|
      unless File.exists?(line)
        line = File.join(pwd, line)
      end

      if File.exists?(line)
        if File.directory?(line)
          found = []
          Dir.glob(File.join(line, '**/*.rb')) { |f| found << File.expand_path(f) }
          found
        else
          File.expand_path line
        end
      else
        nil
      end
    end.flatten.compact # remove nested arrays & nils

    define_reload to_require
  else
    puts "This folder doesn't contain an appium.txt listing page objects"
    exit
  end

  $stdout.puts "pry #{cmd.join(' ')}"
  Pry::CLI.parse_options cmd
end # module Appium::Console