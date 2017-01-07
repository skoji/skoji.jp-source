require 'yaml'
y = YAML.load File.read(ARGV[0])
y['date'] = DateTime.now.to_s
y['categories'] = ['未分類']
File.write ARGV[0], YAML.dump(y) + "---\n"


