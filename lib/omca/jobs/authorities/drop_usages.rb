# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class DropUsages
        include Omca::DynamicCsvJobable

        def self.desc = "Drop field usages tagged in mappings for usage "\
          "removal"

        def source = :non_refname_auth__usages_final

        def destination = :authorities__drop_usages

        def job_code
          xan_result = `#{cmd}`.chomp
          File.open(destination_path, "w") { |f| f << xan_result }
        end

        private

        def removals = Omca::Mappings::Fields.usage_removals

        def filters = removals.map do |arr|
          "not(table eq \"#{arr.first}\" && field eq \"#{arr.last}\")"
        end.join(" && ")

        def cmd = "xan filter '#{filters}' #{source_path}"
      end
    end
  end
end
