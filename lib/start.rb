# encoding: utf-8
require 'rubygems'
require 'spec' # https://github.com/bootstraponline/spec
require 'selenium-webdriver'

$driver = Selenium::WebDriver.for :firefox
$driver.manage.timeouts.implicit_wait = 30 # seconds

# Load minitest
begin
  require 'minitest'
  require 'minitest/spec'
  # set current_spec. fixes:
  # NoMethodError: undefined method `assert_equal' for nil:NilClass
  Minitest::Spec.new 'pry'
rescue
end

module Pages; end

# Promote methods to top level for Pry
# Pages module is hard coded.
def promote_page_object_methods
  ::Pages.constants.each do |class_name|
    puts "Promoting class_name as method #{class_name.to_s.downcase}"
    Kernel.send(:define_method, class_name.to_s.downcase) do
      Pages.const_get(class_name)
    end
  end
end

def reload
  Pry.send :_reload
  promote_page_object_methods
  nil
end

def set_wait seconds
  $driver.manage.timeouts.implicit_wait = seconds
end

# -- helper methods
module Kernel
  def id id
    $driver.find_elements(:id, id).detect { |ele| ele.displayed? }
  end

  def css css
    $driver.find_elements(:css, css).detect { |ele| ele.displayed? }
  end

  def xpath xpath
    $driver.find_elements(:xpath, xpath).detect { |ele| ele.displayed? }
  end

  def link text
    xpath("//a[text()='#{text}']")
  end

  def input input
    xpath("//input[@value='#{input}']")
  end
end
# --

def x
  $driver.quit if $driver
  exit
end

# Ensure page objects are loaded
reload
# Default wait to 0
set_wait 0

# Don't print page objects
# default print code from https://github.com/pry/pry/blob/master/lib/pry.rb
# pry-0.9.12.3
Pry.config.print = proc do |output, value|
  unless value.nil? || value.inspect.to_s.include?('SeleniumWebDriver::PageObject')
    Pry::output_with_default_format(output, value, :hashrocket => true)
  end
end

# loop through all pages and output the methods
def page
  Pages.constants.each do |page|
    methods = Pages.const_get(page).singleton_methods
    methods.each { |m| puts "#{page.to_s.downcase}.#{m}" }
  end
  nil
end