# frozen_string_literal: true

module Omca
  module Jobs
    module FixTableData
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
            destination: dest
          },
          transformer: xforms(table, tabletype, rectype)
        )
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
          if tabletype == "main" && Omca::Mappers.authority?(rectype)
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: Omca::Authorities.used_tag_field,
              value: "y"

          end
        end
      end
    end
  end
end
