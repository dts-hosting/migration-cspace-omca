# frozen_string_literal: true

module Omca
  module Jobs
    class NewRefnameUsagesSplit
      include Omca::DynamicCsvJobable

      def self.desc(table_field) = "Extract usages for #{table_field} from "\
        ":authorities__usages_new_refname"

      def initialize(table:, field:)
        @table = table
        @field = field
      end

      def source = :authorities__usages_new_refname

      def destination = :"new_refname_usages_split__#{table}_#{field}"

      def job_code
        unless Omca::Authmerge.merge_prep_ready?
          return Kiba::Extend::Jobs::NullJob.new(files: {
            source: source,
            destination: destination
          })
        end

        cmd = %(xan filter 'table eq "#{table}" && ) +
          %(field eq "#{field}"' #{source_path} > #{destination_path})

        `#{cmd}`
      end

      private

      attr_reader :table, :field
    end
  end
end
