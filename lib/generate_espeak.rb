#!/usr/bin/env ruby

f = File.readlines("../items_metadata")

f.each do |line|
  arr = line.split(" ")
  file = arr[0]
  channel = arr[1]
  title = arr.slice(2,arr.length).join(" ")
  puts title
  `espeak -v en "#{title}" --stdout > "#{file}_title.wav"`
  sleep 1
  c = channel.gsub("_", " ")
  `espeak -v en "#{c}" --stdout > "#{file}_channel.wav"`
  sleep 1
end
