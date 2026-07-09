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

      # @return [Array<Hash>] of rows representing migrating fields
      def migrating
        @migrating ||=
          fields_sheet.select { |row| row["migrating?"] == "y" }
      end

      # @param rectype [String]
      # @param side [:source, :target] of migration
      # @return [Array<Hash>] of rows representing migrating fields
      def for_rectype(rectype, side: :source)
        migrating.select { |row| row["#{side}_record_type"] == rectype }
      end

      # @param table [String]
      # @return [Array<Hash>] of migrating rows where data comes from db table
      def for_table(table)
        fields_sheet.select { |row| row["source_db_table"] == rectype }
      end

      # @param rectype [String]
      # @param tabletype [String]
      # @return [Array<Hash>] of migrating rows
      def skeleton_fields(rectype, tabletype)
        for_rectype(rectype, side: :target).select do |r|
          r["mapping_treatment"]&.match?("skeleton") &&
            r["db_table_type"] == tabletype
        end
      end

      # @return [Array<String>]
      def skeleton_rectypes
        migrating.select do |row|
          row["mapping_treatment"]&.include?("skeleton")
        end.map { |row| row["target_record_type"] }
          .uniq
          .sort
      end

      # @return [Array<String>]
      def target_rectypes
        migrating.map { |row| row["target_record_type"] }
          .uniq
          .sort
      end

      def uncontrol_rectypes
        migrating.select do |row|
          row["mapping_treatment"]&.include?("uncontrol")
          end.map { |row| row["target_record_type"] }
          .uniq
          .sort
      end

      def uncontrol_rows_for_rectype(rectype)
        for_rectype(rectype).select do |row|
          row["mapping_treatment"]&.include?("uncontrol")
        end
      end

      def usage_removals
        fields_sheet.select do |row|
          row["mapping_treatment"]&.include?("uncontrol and remove usage")
        end.map { |r| [r["source_db_table"], r["db_field"]] }
      end
    end
  end
end
