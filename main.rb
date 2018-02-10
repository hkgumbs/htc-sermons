#!/usr/bin/env ruby

require 'watir'

def run(browser)
  browser.goto 'google.com'
  browser.text_field(title: 'Search').set 'Hello World!'
  browser.input(type: 'submit', value: 'Google Search').click
  puts browser.title
ensure
  browser.quit
end

run Watir::Browser.new(:chrome, headless: true)
