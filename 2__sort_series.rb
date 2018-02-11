#!/usr/bin/env ruby

require 'json'
require 'mp3info'
require 'open-uri'


def run(all_sermons)
  all_sermons.group_by { |hash| hash[:heading] }.map do |series, sermons|
    sort_series series, sermons
  end
end

def sort_series(series, sermons)
  `mkdir -p "#{series_dir series}"`

  with(sermons.find { |hash| hash[:image] }) do |sermon|
    download(sermon[:image], image_file(series, sermon[:image]))
  end

  sermons.reverse.each_with_index do |sermon, index|
    download_sermons(series, sermon, index + 1)
  end
end

def download_sermons(series, sermon, number)
  with(sermon[:href]) do |url|
    file = audio_file series, number
    download url, file
    force_mp3 url, file
    audio_medadata file, series, sermon, number
  end
end

def with(object)
  yield object if !object.nil?
end

def download(url, file)
  IO.copy_stream(open(url), file)
end

def series_dir(name)
  "assets/#{name.gsub(/[^0-9A-Za-z.\-]/, '_')}"
end

def image_file(series, name)
  if name =~ /\.(jpg|jpeg|JPG|JPEG)/
    "#{series_dir series}/image.jpg"
  elsif name =~ /\.(png|PNG)/
    "#{series_dir series}/image.png"
  else
    "#{series_dir series}/image.UNKNOWN"
  end
end

def audio_file(series, index)
  "#{series_dir series}/#{index.to_s.rjust 3, '0'}.mp3"
end

def force_mp3(url, original)
  if match = url.match(/\.(wav|m4a|wma)/)
    tmp = "#{original}.tmp.#{match[1]}"
    `mv #{original} #{tmp}`
    `ffmpeg -i #{tmp} -codec:a libmp3lame -qscale:a 9 #{original}`
  elsif url !~ /\.mp3/
    puts "ERROR { type: extension, url: '#{url}, file: #{original} }"
  end
end

def audio_medadata(file, series, sermon, number)
  Mp3Info.open(file, parse_tags: true, parse_mp3: false) do |mp3|
    mp3.tag.album    = series
    mp3.tag.tracknum = number
    mp3.tag.title    = sermon[:title]
    mp3.tag.artist   = sermon[:preacher]
  end
rescue => e
  puts "ERROR { type: encoding, file: #{file} }"
end


# MAIN

run JSON.parse(File.read('assets/sermons.json'), symbolize_names: true)
