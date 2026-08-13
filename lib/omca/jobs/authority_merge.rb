# frozen_string_literal: true

module Omca
  module Jobs
    module AuthorityMerge
      module_function

      # @param source [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param tabletype [String]
      # @param rectype [String]
      def job(source:, dest:, table:, tabletype:, rectype:)
        by_table = Omca::Authmerge.by_table
        lkups = get_lookup(by_table, table)

        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: lkups
          },
          transformer: xforms(table, by_table, lkups)
        )
      end

      def get_lookup(by_table, table)
        return [] unless by_table.key?(table)

        by_table[table].map { |field| :"auth_merge_prep__#{table}_#{field}" }
      end

      def xforms(table, by_table, lkups)
        Kiba.job_segment do
          if by_table.key?(table)
            lkups.each do |lkup|
              transform Omca::Xforms::AuthorityMerge,
                lookup: send(lkup)
            end
          end
        end
      end
    end
  end
end
