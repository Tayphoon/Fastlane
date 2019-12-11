module Fastlane
  module Actions
  	class IdeviceDebugAction < Action

  		def self.run(params)
        require 'plist'

        bundle_id = params[:bundle_id]

        if !bundle_id then
          bundle_id = FastlaneCore::IpaFileAnalyser.fetch_app_identifier(params[:ipa_path])
          UI.error!("Couldn't find app bundle identifier") unless bundle_id
        end

        if !bundle_id then
          raise ArgumentError.new("Couldn't find app bundle identifier")
        end

        FastlaneCore::PrintTable.print_values(config: params,
                                              title: "Summary for iDevice Debug")

        UI.message("Get device identifiers")
        device_ids = uuids_options(params)
        UI.message("Found device with identifiers #{device_ids}\n")

        result = ""

        device_ids.each do |device_id|
          UI.message("Start app #{bundle_id} on device with id #{device_id}\n")

          command = "idevicedebug"
          command << " -e #{params[:extra]}"
          command << " -u #{device_id}"
          command << " run #{bundle_id}"

          command_output = ""
          begin
            command_output = sh_execute(command)
          rescue => ex
            UI.message("Failed start app #{bundle_id} for device with id #{device_id} error: #{ex.message}\n")
          end

          result += "#{command_output}\n"

        end

        log_file = params[:log_file];
        if log_file
          File.open(log_file, "a") do |file|
            file.write(result)
          end
        end

      end

      def self.uuids_options(params)
        device_ids = []
        if params[:device_id] then
          device_ids += [params[:device_id]]
          UI.message("Use devices with identifiers #{device_ids}\n")
        else
          UI.message("Get device identifiers")
          device_ids = (Actions.sh("idevice_id -l", log: false)).split("\n").uniq
          UI.message("Found devices with identifiers #{device_ids}\n")
        end

        device_ids
      end

      def self.sh_execute(command)
        command = command.join(' ') if command.kind_of?(Array) # since it's an array of one element when running from the Fastfile
        UI.command(command)

        result = ''
        if Helper.sh_enabled?
          exit_status = nil
          IO.popen(command, err: [:child, :out]) do |io|
            io.sync = true
            io.each do |line|
              UI.command_output(line.strip)
              result << line
            end
            io.close
            exit_status = $?.exitstatus
          end

          if exit_status != 0
            message = "Shell command exited with exit status #{exit_status} instead of 0."
            message += "\n#{result}"
            UI.message(message)
          end
        else
          result << command # only for the tests
        end

        result
      rescue => ex
        raise ex

      end

    	#####################################################
    	# @!group Documentation
    	#####################################################
        def self.description
        	'idevice debug tool'
      	end

        def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :extra,
                                       short_option: "-e",
                                       env_name: "FL_IOD_EXTRA",
                                       description: "Extra Commandline arguments passed to idevicedebug",
                                       optional: true,
                                       is_string: true),

          FastlaneCore::ConfigItem.new(key: :device_id,
                                       short_option: "-u",
                                       env_name: "FL_IOD_DEVICE_ID",
                                       description: "id of the device / if not set defaults to all found device",
                                       optional: true,
                                       is_string: true,
                                       default_value: Actions.lane_context['DEVICE_ID']),

          FastlaneCore::ConfigItem.new(key: :bundle_id,
                                       short_option: "-b",
                                       env_name: "FL_IOD_BUNDLE_ID",
                                       description: "bundle_id of the app / if not set try ro get it from ipa",
                                       optional: true,
                                       is_string: true),

          FastlaneCore::ConfigItem.new(key: :log_file,
                                       short_option: "-o",
                                       env_name: "FL_IOD_LOG_FILE",
                                       description: "Path to output file",
                                       optional: true,
                                       is_string: true),

          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       short_option: "-i",
                                       env_name: "FL_IOD_IPA",
                                       description: "The IPA file to put on the device",
                                       optional: true,
                                       is_string: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Dir["*.ipa"].first)

        ]
      end

      def self.authors
        	["Tayphoon"]
      end

      def self.is_supported?(platform)
        	[:ios].include?(platform)
      end

      def self.example_code
        [
          'idevice_debug',
          'idevice_debug(
            extra: "...",
            device_id: "..."
          )'
        ]
      end
  	end
  end
end
