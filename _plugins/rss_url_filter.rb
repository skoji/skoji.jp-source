module Jekyll
  module URLRelativePathFilter
    def relative_urls_to_absolute input
      url = @context.registers[:site].config['url'] || 'http://example.com'
      input.gsub('src="/', 'src="' + url + '/').gsub('href="/', 'href="' + url + '/')
    end
    def relative_raw_url_to_absolute input
      url = @context.registers[:site].config['url'] || 'http://example.com'      
      input.sub(/^\//, "#{url}/")
    end
  end
end

Liquid::Template.register_filter(Jekyll::URLRelativePathFilter)
