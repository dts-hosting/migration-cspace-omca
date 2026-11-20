# frozen_string_literal: true

module Omca
  module Jobs
    class SplitUsagesForRefnameLkup
      include Omca::DynamicCsvJobable

      def self.desc(type_subtype)
        "Extracts :#{Omca.auth_usages} rows for #{type_subtype} terms, for "\
          "new refnames to be merged into"
      end

      def initialize(type:, subtype:)
        @type = type
        @subtype = subtype
      end

      def source = Omca.auth_usages

      def destination = :"split_usages_for_refname_lkup__#{type}_#{subtype}"

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
