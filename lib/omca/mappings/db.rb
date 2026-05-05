# frozen_string_literal: true

module Omca
  module Mappings
    module Db
      module_function

      def db_tables_sheet = @db_tables_sheet ||=
                              Omca::Mappings.worksheet
                                .sheet("db_tables").parse(headers: true)

      def main_table_rows = @main_table_rows ||=
                              db_tables_sheet.select do |row|
                                row["table_type"] == "main rectype"
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
                                    row["table_type"] == "additional fields"
                                  end
                                    .map do |r|
                                      [r["table_name"],
                                        main_tables_by_rectype[r["rectype"]]]
                                    end

      def group_tables = @group_tables ||=
                           db_tables_sheet.select do |row|
                             row["table_type"] == "group" ||
                               row["table_type"] == "group, multi-rectype"
                           end
                             .map { |r| r["table_name"] }

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
