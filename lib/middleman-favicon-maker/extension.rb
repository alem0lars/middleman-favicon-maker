require "favicon_maker"
require "pathname"

module Middleman
  module FaviconMaker
    class FaviconMakerExtension < Extension

      option :template_dir, nil, "Template dir for icon templates"
      option :output_dir,   nil, "Output dir for generated icons"
      option :icons,        {},  "Hash with template filename (key) and Array of Hashes with icon configs"

      def after_configuration
        options[:template_dir] ||= source_path
        options[:output_dir]   ||= build_path
      end

      def after_build(builder)

        template_files = []
        ::FaviconMaker.generate do
          setup do
            template_dir  options[:template_dir]
            output_dir    options[:output_dir]
          end

          options[:icons].each do |input_filename, icon_configs|
            from input_filename do
              icon_configs.each do |icon_config|
                icon icon_config[:icon], icon_config
              end
            end
          end

          each_icon do |filepath, template_filepath|
            rel_path = Pathname.new(filepath).relative_path_from(Pathname.new(app.root)).to_s
            builder.trigger(:create, nil, rel_path)
          end
        end

      end

      private

      def source_path
        File.join(app.root, app.config.source)
      end

      def build_path
        File.join(app.root, app.config.build_dir)
      end
    end
  end
end
