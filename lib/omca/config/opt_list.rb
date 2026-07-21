# frozen_string_literal: true

module Omca
  module OptList
    module_function

    extend Dry::Configurable

    # tabletype (source) > table > field Hash of fields that are mapping
    #   to option list-controlled target fields. Used to extract values
    #   for customizing the option lists in hosted UI config
    def source_fields_to_opt_list
      result = {}
      Omca::Mappings::Fields.opt_list_controlled_target_rows.each do |row|
        tt = row["db_table_type"]
        table = row["source_db_table"]
        field = row["db_field"]
        optlist = row["target_field_source"].delete_prefix("option list: ")

        table_info = [tt, table]
        result[table_info] = [] unless result.key?(table_info)

        result[table_info] << [optlist, field]
      end
      result
    end
  end
end
