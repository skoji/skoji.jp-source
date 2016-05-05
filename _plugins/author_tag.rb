module Jekyll
  module AuthorFilter
    def get_author(input)
   	  (input.is_a? String) ? input : input["display_name"]
    end      
  end
end
Liquid::Template.register_filter(Jekyll::AuthorFilter)
