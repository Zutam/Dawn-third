# frozen_string_literal: true
require "json"
module Theme
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("--name=NAME") { |t| flags[:title] = t }
        parser.on("--env=ENV") { |env| flags[:env] = env }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        build(form.name)
        ShopifyCli::Project.write(@ctx,
          project_type: "theme",
          organization_id: nil) # private apps are different

        @ctx.done(@ctx.message("theme.create.info.created", form.name, ShopifyCli::AdminAPI.get_shop(@ctx), @ctx.root))
      end

      def self.help
        ShopifyCli::Context.message("theme.create.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def build(name)
        @ctx.abort(@ctx.message("theme.create.duplicate_theme")) if @ctx.dir_exist?(name)
        @ctx.mkdir_p(name)
        @ctx.chdir(name)

        CLI::UI::Frame.open(@ctx.message("theme.create.creating_theme", name)) do
          create(name)
        rescue
            @ctx.chdir("..")
            @ctx.rm_rf(name)
            @ctx.abort("Failed to create theme")
        end
      end

      def create(name)
        # create the skeleton
        create_directories
        upload_theme(name)
        true
      end

      def create_directories
        @ctx.mkdir_p("assets")
        @ctx.mkdir_p("config")
        @ctx.mkdir_p("layout")
        @ctx.mkdir_p("locales")
        @ctx.mkdir_p("templates")
        settings_data = <<~SETTINGS_DATA
          {
            "current": "Default",
            "presets": {
              "Default": { }
            }
          }
        SETTINGS_DATA

        settings_schema = <<~SETTINGS_SCHEMA
          [
            {
              "name": "theme_info",
              "theme_name": "Shopify CLI template theme",
              "theme_version": "1.0.0",
              "theme_author": "Shopify",
              "theme_documentation_url": "https://github.com/Shopify/shopify-app-cli",
              "theme_support_url": "https://github.com/Shopify/shopify-app-cli/issues"
            }
          ]
        SETTINGS_SCHEMA

        @ctx.write("config/settings_data.json", settings_data)
        @ctx.write("config/settings_schema.json", settings_schema)
      end

      def upload_theme(name)
        # uploads new theme to shopify (is this needed?)
        params = {
          "theme": {
            "name": name,
          },
        }
        response = ShopifyCli::AdminAPI.rest_request(
          @ctx,
          shop: ShopifyCli::AdminAPI.get_shop(@ctx),
          path: "themes.json",
          body: params.to_json,
          method: "POST",
          api_version: "unstable",
        )
        if response[0]!= 201
          ctx.abort("Failed to connect theme to Shopify")
        end
        # @ctx.debug(response[1]["theme"]["id"])
      end
    end
  end
end
