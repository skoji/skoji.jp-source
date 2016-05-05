module Jekyll
  module CategoryNameToSlug
    def catname2slug(input)
      slug_map = @context.registers[:site].config['category_slug_map']
      (slug_map && slug_map[input]) || Utils.slugify(input)
    end
  end
end
Liquid::Template.register_filter(Jekyll::CategoryNameToSlug)
