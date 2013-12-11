# encoding: utf-8
require 'rubygems'
require 'spec' # https://github.com/bootstraponline/spec
require 'selenium-webdriver'
require 'page-object' # https://github.com/cheezy/page-object

$browser = Selenium::WebDriver.for :firefox
$browser.manage.timeouts.implicit_wait = 30 # seconds

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

## Pages module is hard coded.
def promote_page_object_methods
  # load in page object methods
  # Expose all classes under the Pages module to minitest
  ::Pages.constants.each do |class_name|
    define_singleton_method class_name.to_s.downcase do
      ivar = "@#{class_name}"
      instance_var = instance_variable_get ivar
      if instance_var
        instance_var
      else
        instance_variable_set ivar, Pages.const_get(class_name).new($browser)
      end
    end
  end
end

def reload
  Pry.reload
  promote_page_object_methods
  nil
end

def set_wait seconds
  $browser.manage.timeouts.implicit_wait = seconds
end

# -- helper methods
module Kernel
  def id id
    $browser.find_elements(:id, id).detect { |ele| ele.displayed? }
  end

  def css css
    $browser.find_elements(:css, css).detect { |ele| ele.displayed? }
  end

  def xpath xpath
    $browser.find_elements(:xpath, xpath).detect { |ele| ele.displayed? }
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
  $browser.quit if $browser
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
    methods = Pages.const_get(page).instance_methods.sort - Object.instance_methods.sort
    methods.each { |m| puts "#{page.to_s.downcase}.#{m}" }
  end
  nil
end