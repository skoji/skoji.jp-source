require 'date'

task :default => :build
task :build do 
  sh 'bundle exec jekyll b'
end

desc "Create a new Jekyll post under _posts/YEAR and set appropriate frontmatters"
task :new_post, [:title] do |t, args|
  abort "Please provide a title for the new post." unless args[:title]
  title = args[:title].strip
  today = Date.today.strftime("%Y-%m-%d")
  year = Date.today.year
  slug  = title.downcase.strip.gsub(/\s+/, "-").gsub(/[^a-z0-9\-]/, "")
  path  = "_posts/#{year}"
  FileUtils.mkdir_p(path)
  file  = "#{path}/#{today}-#{slug}.md"
  File.write(file, <<~EOF)
---
layout: post
title: #{title}
date: '#{DateTime.now.to_s}'
categories:
 - 未分類
---
EOF
  puts file
end
