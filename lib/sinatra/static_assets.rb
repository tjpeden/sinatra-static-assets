class Array
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

module Sinatra
  module StaticAssets
    module Helpers
      def image_tag(source, options = {})
        options[:src] = "/images/#{source}"
        tag("img", options)
      end

      def stylesheet_link_tag(*sources)
        options = sources.extract_options!
        sources.collect { |source| stylesheet_tag(source, options) }.join("\n")
      end

      def javascript_include_tag(*sources)
        options = sources.extract_options!
        sources.collect { |source| javascript_tag(source, options) }.join("\n")
      end

      def link_to(desc, url, options = {})
        tag( "a", options.merge(:href => url) ) do
          desc
        end
      end

      private

      def tag(name, local_options = {})
        start_tag = "<#{name}#{tag_options(local_options) if local_options}"
        if block_given?
          content = yield
          "#{start_tag}>#{content}</#{name}>"
        else
          "#{start_tag}/>"
        end
      end

      def tag_options(options)
        unless options.empty?
          attrs = []
          attrs = options.map { |key, value| %(#{key}="#{Rack::Utils.escape_html(value)}") }
          " #{attrs.sort * ' '}" unless attrs.empty?
        end
      end

      def stylesheet_tag(source, options = {})
        source = "/stylesheets/#{source}" unless source =~ /\//
        source = "#{source}.css" unless source =~ /\.css$/
        tag("link", { :type => "text/css",
            :charset => "utf-8", :media => "screen", :rel => "stylesheet",
            :href => source }.merge(options))
      end

      def javascript_tag(source, options = {})
        source = "/javascripts/#{source}" unless source =~ /\//
        source = "#{source}.js" unless source =~ /\.js$/
        tag("script", { :type => "text/javascript", :charset => "utf-8",
            :src => source} }.merge(options)) {}
      end

      def extract_options!(a)
        a.last.is_a?(::Hash) ? a.pop : {}
      end

    end

    def self.registered(app)
      app.helpers StaticAssets::Helpers
      app.disable :xhtml
    end
  end

  register StaticAssets
end
