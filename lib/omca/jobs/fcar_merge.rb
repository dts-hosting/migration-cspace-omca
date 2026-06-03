# frozen_string_literal: true

module Omca
  module Jobs
    module FcarMerge
      module_function

      # @param source [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param tabletype [String]
      # @param rectype [String]
      def job(source:, dest:, table:, tabletype:, rectype:)
        Omca::Dependencies.ensure_fix(table)

        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: get_lookups
          },
          transformer: xforms(table, tabletype, rectype)
        )
      end

      def get_lookups
        base = []
        base << :big_auth__final if Omca::BigAuthFcar.cleanup_done?
        base
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
          if Omca::BigAuthFcar.cleanup_done?
            if big_auth__final.key?(rectype)
              transform Omca::Xforms::BigAuthMerge,
                table: table,
                tabletype: tabletype,
                rectype: rectype,
                mergerows: big_auth__final[rectype]
            end
          end
        end
      end
    end
  end
end
