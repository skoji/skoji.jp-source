require 'json'
module Jekyll
  module StripFilters
    def strip_figure(input)
      input.sub(/<figure>.*?<\/figure>/m, '')
    end
    def replace_newlines_to_space(input)
      input.gsub(/\R/m, ' ');
    end
    def to_json(input)
      input.to_json
    end
  end
end
Liquid::Template.register_filter(Jekyll::StripFilters)
