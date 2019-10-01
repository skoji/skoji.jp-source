require 'yaml'
require 'date'
file = ARGV[0].gsub(/\e\[\d{1,3}[mK]/, '')
y = YAML.load File.read(file)
y['date'] = DateTime.now.to_s
y['categories'] = ['未分類']
File.write file, YAML.dump(y) + "---\n"
puts file


