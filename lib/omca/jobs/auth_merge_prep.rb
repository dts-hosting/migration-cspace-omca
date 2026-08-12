# frozen_string_literal: true

module Omca
  module Jobs
    class AuthMergePrep
      include Omca::DynamicCsvJobable

      def initialize(table:, field:)
        @table = table
        @field = field
      end

      def source = :authorities__usages_new_refname

      def destination = :"auth_merge_prep__#{table}_#{field}"

      def job_code
        cmd = %(xan filter 'table eq "#{table}" && ) +
          %(field eq "#{field}"' #{source_path} > #{destination_path})

        `#{cmd}`
      end

      def outrows
        ct = `xan count #{destination_path}`.chomp
        "#{ct} rows"
      end

      private

      attr_reader :table, :field
    end
  end
end
