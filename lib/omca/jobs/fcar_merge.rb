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
        base << :big_auth__non_collapsing if Omca::BigAuthFcar.cleanup_done?
        base.select { |key| Kiba::Extend::Job.output?(key) }
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
          if Omca::BigAuthFcar.cleanup_done? &&
              respond_to?(:big_auth__non_collapsing) &&
              big_auth__non_collapsing.key?(rectype)

            if table == Omca::Mappers.term_table_for(rectype)
              transform Omca::Xforms::BigAuthMergeTerm,
                table: table,
                tabletype: tabletype,
                rectype: rectype,
                mergerows: big_auth__non_collapsing[rectype]
            end

            if tabletype == "main"
              transform Omca::Xforms::BigAuthMergeMain,
                table: table,
                tabletype: tabletype,
                rectype: rectype,
                mergerows: big_auth__non_collapsing[rectype]
            end
          end
        end
      end
    end
  end
end
