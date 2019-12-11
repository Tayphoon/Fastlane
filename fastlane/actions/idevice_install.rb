module Fastlane
  module Actions
  	class IdeviceInstallAction < Action

  		def self.run(params)

        FastlaneCore::PrintTable.print_values(config: params,
                                              title: "Summary for iDevice Install")

        UI.message("Get device identifiers")
        device_ids = uuids_options(params)

        UI.message("Install into device ids #{device_ids}\n")

        result = ""

        device_ids.each do |device_id|

          command = "ideviceinstaller -u #{device_id} -i '#{params[:ipa_path]}'"
          begin
            Actions.sh(command)
          rescue => ex
            UI.message("Failed install ipa #{params[:ipa_path]} for device with id #{device_id} error: #{ex.message}\n")
          end

        end

      end

      def self.uuids_options(params)
        device_ids = []
        if params[:device_id] then
          device_ids += [params[:device_id]]
        else
          UI.message("Get device identifiers")
          device_ids = (Actions.sh("idevice_id -l", log: false)).split("\n").uniq
          UI.message("Found devices with identifiers #{device_ids}\n")
        end

        device_ids
      end

    	#####################################################
    	# @!group Documentation
    	#####################################################
        def self.description
        	'idevice install utilities'
      	end

        def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :device_id,
                                       short_option: "-u",
                                       env_name: "FL_IOD_DEVICE_ID",
                                       description: "id of the device / if not set defaults to all found device",
                                       optional: true,
                                       is_string: true,
                                       default_value: Actions.lane_context['DEVICE_ID']),

          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       short_option: "-i",
                                       env_name: "FL_IOD_IPA",
                                       description: "The IPA file to put on the device",
                                       optional: true,
                                       is_string: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Dir["*.ipa"].first,
                                       verify_block: proc do |value|
                                         unless Helper.test?
                                           UI.user_error!("Could not find IPA file at path '#{value}'") unless File.exist? value
                                           UI.user_error!("'#{value}' doesn't seem to be an IPA file") unless value.end_with? ".ipa"
                                         end
                                       end)
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
          'idevice_install',
          'idevice_install(
            device_id: "...",
            ipa_path: "..."
          )'
        ]
      end
  	end
  end
end
