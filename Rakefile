task :default => :build
task :build do 
  sh 'bundle exec jekyll b'
  sh 'node preindex.js < _site/search_data.json > _site/search_data_indexed.json'
end
