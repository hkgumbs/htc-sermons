#!/usr/bin/env ruby

require 'json'
require 'watir'

$sermons = []
$heading = { title: '', image: nil }

def run(browser)
  browser.goto 'http://htcchicago.org/resources/sermons'
  loop do
    puts browser.url
    browser.wait
    get_sermons(browser)
    break unless browser.a(id: 'next').present?
    browser.a(id: 'next').click
  end
ensure
  browser.quit
end

def get_sermons(browser)
  browser.div(id: 'text').children.each do |el|
    if el.class_name == 'series_heading'
      $heading = {
        title: el.h4.text,
        image: maybe(el.img, :src),
      }
    else
      $sermons << {
        heading:  $heading[:title],
        image:    $heading[:image] || maybe(el.img, :src),
        title:    el.header.h3.a.text,
        time:     el.header.p(class: 'time').text,
        href:     maybe(el.header.ul.li(class: 'download').a, :href),
        preacher: maybe(el.header.p(class: 'meta', text: /Preacher/), :text),
      }
    end
  end
end

def maybe(el, method)
  el.exists? ? el.send(method) : nil
end


# MAIN

Watir::Browser.new(:chrome, headless: true).tap { |browser| run browser }
File.open('build/sermons.json', 'w') { |f| f.write($sermons.to_json) }
