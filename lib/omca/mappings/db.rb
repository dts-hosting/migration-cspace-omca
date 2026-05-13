# frozen_string_literal: true

module Omca
  module Mappings
    module Db
      module_function

      def db_tables_sheet = @db_tables_sheet ||=
                              Omca::Mappings.worksheet
                                .sheet("db_tables").parse(headers: true)

      # @param table [String]
      def rectype_for_table(table) = val_from_table_row(
        table, "rectype"
      )

      # @param table [String]
      # @param mode [:info, :dir]
      def table_type(table, mode = :info)
        type = val_from_table_row(table, "table_type")
        return unless type
        return if mode == :info

        type.tr(" ", "_")
      end

      def val_from_table_row(table, val)
        row = db_tables_sheet.find do |row|
          row["table_name"] == table
        end
        return unless row

        row[val]
      end

      def main_table_rows = @main_table_rows ||=
                              db_tables_sheet.select do |row|
                                row["table_type"] == "main"
                              end

      # @return [Array<String>] database table names of main rectype tables
      def main_tables = @main_tables ||=
                          main_table_rows.map { |row| row["table_name"] }

      # @return [Hash] keys are rectypes; values are main table names
      def main_tables_by_rectype = @main_tables_by_rectype ||=
                                     main_table_rows.map do |row|
                                       [row["rectype"], row["table_name"]]
                                     end
                                       .to_h

      def rectypes = @rectypes ||= main_tables_by_rectype.keys

      # @return [Hash] keys are main table names; values are rectypes
      def rectypes_by_main_table = @rectypes_by_main_table ||=
                                     main_table_rows.map do |row|
                                       [row["table_name"], row["rectype"]]
                                     end
                                       .to_h

      def repeating_field_tables = @repeating_field_tables ||=
                                     db_tables_sheet.select do |row|
                                       row["table_type"] == "repeatable field"
                                     end
                                       .map do |r|
                                         [r["table_name"],
                                           main_tables_by_rectype[r["rectype"]]]
                                       end

      def addtl_fields_tables = @addtl_fields_tables ||=
                                  db_tables_sheet.select do |row|
                                    row["table_type"] == "addtl_fields"
                                  end
                                    .map do |r|
                                      [r["table_name"],
                                        main_tables_by_rectype[r["rectype"]]]
                                    end

      def repeatable_field_group_tables
        @repeatable_field_group_tables ||=
          db_tables_sheet.select do |row|
            row["table_type"] == "repeatable_field_group"
          end
            .map { |r| r["table_name"] }
            .reject { |e| e == "dategroup" || e == "structureddategroup" }
      end

      def extension_field_group_tables
        @extension_field_group_tables ||=
          db_tables_sheet.select do |row|
            row["table_type"] == "extension_field_group"
          end
            .map { |r| r["table_name"] }
            .reject { |e| e == "dategroup" || e == "structureddategroup" }
      end

      def repeatable_in_group_tables = @repeatable_in_group_tables ||=
                                         db_tables_sheet.select do |row|
                                           row["table_type"] ==
                                             "repeatable in group"
                                         end
                                           .map { |r| r["table_name"] }

      def subgroup_tables = @subgroup_tables ||=
                              db_tables_sheet.select do |row|
                                row["table_type"].start_with?("subgroup")
                              end
                                .map { |r| r["table_name"] }
    end
  end
end
