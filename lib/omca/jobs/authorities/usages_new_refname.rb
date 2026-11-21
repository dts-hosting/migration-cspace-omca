# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class UsagesNewRefname
        include Omca::DynamicCsvJobable

        def self.desc = "Concatenate all refname_usage_merge output rows "\
          "into one big usages file."

        def source = source_entries.map { |e| e.key.to_sym }

        def destination = :authorities__usages_new_refname

        def job_code
          `#{cmd}`
        end

        private

        def source_entries = Kiba::Extend::Command::Jobs::TaggedOr.call(
          "refname_usage_merge"
        )

        def output_entry_paths = source_entries.select do |e|
          Kiba::Extend::Job.output?(e.key.to_sym)
        end.map(&:path)
          .join(" ")

        def cmd
          "xan cat rows #{output_entry_paths} > #{destination_path}"
        end
      end
    end
  end
end
