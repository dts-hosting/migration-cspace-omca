# frozen_string_literal: true

module Omca
  module Mappings
    module Db
      module_function

      def db_tables_sheet = @db_tables_sheet ||=
                              Omca::Mappings.worksheet
                                .sheet("db_tables").parse(headers: true)

      def migrating_tables = db_tables_sheet.select do |r|
        r["migrating"] == "y"
      end

      # @param table [String]
      def rectype_for_table(table) = val_from_table_row(
        table, "rectype"
      )

      # @param table [String]
      # @param mode [:info, :dir]
      def table_type(table, mode = :info)
        type = val_from_table_row(table, "table_type")
        return unless type
        return type if mode == :info

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
                              migrating_tables.select do |row|
                                row["table_type"] == "main"
                              end

      # @return [Hash] keys are rectypes; values are main table names
      def main_tables_by_rectype
        @main_tables_by_rectype ||=
          main_table_rows.map { |row| [row["rectype"], row["table_name"]] }
            .to_h
      end

      def rectypes = @rectypes ||= main_tables_by_rectype.keys

      # @return [Hash] keys are main table names; values are rectypes
      def rectypes_by_main_table
        @rectypes_by_main_table ||=
          main_table_rows.map { |row| [row["table_name"], row["rectype"]] }
            .to_h
      end

      def addtl_fields_tables
        @addtl_fields_tables ||=
          migrating_tables.select { |row| row["table_type"] == "addtl_fields" }
            .map do |r|
              [r["table_name"],
                main_tables_by_rectype[r["rectype"]]]
            end
      end

      def extension_field_group_tables
        @extension_field_group_tables ||=
          migrating_tables.select do |row|
            row["table_type"] == "extension_field_group"
          end.map { |r| r["table_name"] }
            .reject { |e| e == "dategroup" || e == "structureddategroup" }
      end

      def extension_subgroup_tables
        @extension_subgroup_tables ||=
          migrating_tables.select do |row|
            row["table_type"] == "extension_subgroup"
          end.map { |r| r["table_name"] }
      end

      # @return [Array<String>] database table names of main rectype tables
      def main_tables = @main_tables ||=
                          main_table_rows.map { |row| row["table_name"] }

      def repeatable_field_tables
        @repeatable_field_tables ||=
          migrating_tables.select do |row|
            row["table_type"] == "repeatable_field"
          end.map do |r|
            [r["table_name"], main_tables_by_rectype[r["rectype"]]]
          end
      end

      def repeatable_field_group_tables
        @repeatable_field_group_tables ||=
          migrating_tables.select do |row|
            row["table_type"] == "repeatable_field_group"
          end.map { |r| r["table_name"] }
            .reject { |e| e == "dategroup" || e == "structureddategroup" }
      end

      def repeatable_in_group_tables
        @repeatable_in_group_tables ||=
          migrating_tables.select do |row|
            row["table_type"] == "repeatable_in_group"
          end.map { |r| r["table_name"] }
      end

      def subgroup_tables
        @subgroup_tables ||=
          migrating_tables.select { |row| row["table_type"] == "subgroup" }
            .map { |r| r["table_name"] }
      end

      def source_tables
        Omca::Mappings::Fields.migrating
          .map { |row| row["source_db_table"] }
          .uniq
          .reject { |v| Omca::RegistryData.skip_tables.include?(v) }
      end

      def target_tables(type)
        Omca::Mappings::Fields.migrating
          .select { |row| row["target_db_table_type"] == type }
          .map { |row| row["target_db_table"] }
          .uniq
          .reject { |v| v == "collectionobjects_common_mediaprioritylist" }
      end

      # @return [Array<String>] used to register remap and authmerge phase jobs
      def target_table_types
        Omca::Mappings::Fields.migrating
          .map { |row| row["target_db_table_type"] }
          .uniq
          .reject { |v| v == "structured dates" }
          .map { |v| v.tr(" ", "_") }
      end

      # @param [String] name of parent table into which row(s) should be
      #   merged
      # @return [Hash] where key is table name of child table and value is
      #   the child table's tabletype
      def build_children_config_for(table)
        if table_type(table).end_with?("_field_group")
          build_children_config_for_group(table)
        elsif table_type(table) == "main"
          build_children_config_for_main(table)
        elsif table_type(table) == "subrecord"
          build_children_config_for_subrecord(table)
        else
          {}
        end
      end

      def build_children_config_for_main(table)
        children_config_rows_for_top_level(table).reject do |r|
          r["target_db_table_type"] == "main"
        end.to_h do |r|
          [r["target_db_table"], r["target_db_table_type"]]
        end.merge(
          build_children_config_for_group(table)
        )
      end

      def build_children_config_for_subrecord(table)
        children_config_rows_for_top_level(table).reject do |r|
          r["target_db_table_type"] == "subrecord"
        end.to_h do |r|
          [r["target_db_table"], r["target_db_table_type"]]
        end
      end

      def children_config_rows_for_top_level(table)
        rectype = rectype_for_table(table)
        Omca::Mappings::Fields.for_rectype(rectype, side: :target)
          .reject do |r|
            ["subgroup", "extension_subgroup",
              "structured dates"].include?(r["target_db_table_type"]) ||
              (r["target_db_table"] ==
               "collectionobjects_common_mediaprioritylist")
          end
      end

      def build_children_config_for_group(table)
        migrating_tables.select do |r|
          r["parent_table"]&.match?(table)
        end.reject { |r| r["table_type"] == "structured dates" }
          .to_h { |r| [r["table_name"], r["table_type"]] }
      end

      # @param [String] name of parent table into which row(s) should be
      #   merged
      # @return [Array<String>] of tables that rows from the given table merge
      #   INTO
      def build_children_for(table) = build_children_config_for(table).keys
    end
  end
end
