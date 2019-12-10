module Jekyll
  module StripFigureFilter
    def strip_figure(input)
      input.sub(/<figure>.*?<\/figure>/m, '')
    end      
  end
end
Liquid::Template.register_filter(Jekyll::StripFigureFilter)
