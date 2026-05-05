# frozen_string_literal: true

module Omca
  module Mappings
    module Fields
      module_function

      def fields_sheet
        @fields_sheet ||=
          Omca::Mappings.worksheet
            .sheet("mappings").parse(headers: true)
      end

      # @param rectype [String]
      # @param side [:source, :target] of migration
      # @return [Array<Hash>] of rows representing migrating fields
      def for_rectype(rectype, side: :source)
        fields_sheet.select do |row|
          row["#{side}_record_type"] == rectype &&
            row["migrating?"] == "y"
        end
      end

      # @param table [String]
      # @return [Array<Hash>] of migrating rows where data comes from db table
      def for_table(table)
        fields_sheet.select do |row|
          row["source_db_table"] == rectype && row["migrating?"] == "y"
        end
      end
    end
  end
end
