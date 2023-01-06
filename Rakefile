task :default => :build
task :build do 
  sh 'bundle exec jekyll b'
  sh 'node preindex.js < skoji.jp-root/blog//search_data.json > skoji.jp-root/blog/search_data_indexed.json'
end
