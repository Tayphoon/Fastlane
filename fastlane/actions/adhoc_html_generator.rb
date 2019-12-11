require 'json'
require 'tempfile'

TEMPLATE_PROJECT_HTML_FILENAME = 'fastlane/assets/project_index_template.html'
TEMPLATE_PROJECT_PLIST_FILENAME = 'fastlane/assets/project_plist_template.plist'

module Fastlane
  module Actions
    class AdhocHtmlGeneratorAction < Action
      def self.run(params)

        FastlaneCore::PrintTable.print_values(config: params,
                                              title: "Summary ADHOC html generator")

        @ipa_path = params[:ipa_path]
        @app_identifier = params[:app_identifier]
        @app_name = params[:app_name].gsub(" ", "_")
        @build_version = params[:build_version]
        @output_directory = File.expand_path("./#{params[:output_directory]}")
        @base_url = params[:base_url]

        @html_name = "#{File.basename(@ipa_path, ".ipa")}.html"
        @html_path = URI.parse(URI.encode("#{@output_directory}/#{@html_name}"))

        @plist_name = "#{File.basename(@ipa_path, ".ipa")}.plist"
        @plist_path = URI.parse(URI.encode("#{@output_directory}/#{@plist_name}"))

        @ipa_name = File.basename(@ipa_path)
        @ipa_url = URI.parse(URI.encode("#{@base_url}/#{@ipa_name}"))

        generate_html_files

        UI.message("Successfully generate adhoc files 💾")
      end

      def self.generate_html_files

        begin
          plist_url = "#{@base_url}/#{@plist_name}"

          html_template = IO.read(File.absolute_path(TEMPLATE_PROJECT_HTML_FILENAME))
          html = html_template % {:url => plist_url, :name => @app_name, :bundle_version => @build_version}

          # write result to file
          File.open(@html_path.path, 'w+') do |file|
            file.write html
          end

          plist_template = IO.read(File.absolute_path(TEMPLATE_PROJECT_PLIST_FILENAME))
          plist = plist_template % {:url => @ipa_url,
                                    :bundle_identifier => @app_identifier,
                                    :bundle_version => @build_version,
                                    :title => @app_name,
                                    :changelog => @changelog}

                                    # write result to file
          File.open(@plist_path.path, 'w+') do |file|
            file.write plist
          end
        end
      end

      def self.description
        "Generate adhoc files"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "ADHOC_HTML_IPA_PATH",
                                       description: "Path to ipa file",
                                       is_string: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: "ADHOC_HTML_APP_IDENTIFIER",
                                       description: "Bundle id",
                                       is_string: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "ADHOC_HTML_APP_NAME",
                                       description: "Application name",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :build_version,
                                       env_name: "ADHOC_HTML_BUILD_VERSION",
                                       description: "Build version",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       env_name: "ADHOC_HTML_OUTPUT_DIR",
                                       description: "Output directory",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :base_url,
                                       env_name: "ADHOC_HTML_BASEURL",
                                       description: "Base URL",
                                       is_string: true,
                                       default_value: ENV['ADHOC_HTML_BASEURL'])
        ]
      end

      def self.authors
        ["Tayphoon"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
