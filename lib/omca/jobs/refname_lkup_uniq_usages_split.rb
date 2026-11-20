# frozen_string_literal: true

module Omca
  module Jobs
    class RefnameLkupUniqUsagesSplit
      include Omca::DynamicCsvJobable

      def self.desc(type_subtype)
        "Extracts :authorities__uniq_usage_new_lookup_base rows for "\
          "#{type_subtype} terms"
      end

      def initialize(type:, subtype:)
        @type = type
        @subtype = subtype
      end

      def source = :authorities__uniq_usage_new_lookup_base

      def destination = :"refname_lkup_uniq_usages_split__#{type}_#{subtype}"

      def job_code
        unless Kiba::Extend::Job.output?(source)
          return Kiba::Extend::Jobs::NullJob.new(files: {
            source: source,
            destination: destination
          })
        end

        `#{cmd}`
      end

      private

      attr_reader :type, :subtype

      def cmd = "xan filter '(authority eq \"#{type}\") && "\
        "(vocab eq \"#{subtype}\")' #{source_path}  > #{destination_path}"
    end
  end
end
