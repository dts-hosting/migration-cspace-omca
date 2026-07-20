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
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: get_lookup(table)
          },
          transformer: xforms(table)
        )
      end

      def get_lookup(table)
        key = :"usages_by_table__#{table}"
        return [] unless Kiba::Extend::Job.output?(key, mode: :agnostic)

        [{jobkey: key, lookup_on: :id}]
      end

      def xforms(table)
        Kiba.job_segment do
          lkup = :"usages_by_table__#{table}"
          if respond_to?(lkup)
            transform Omca::Xforms::AuthorityMerge,
              lookup: send(lkup)
          end
        end
      end
    end
  end
end
