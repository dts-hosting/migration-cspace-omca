# frozen_string_literal: true

module Omca
  module Db
    module Queries
      module_function

      def main_table(table_name)
        <<~SQL
          select tbl.*
          from #{table_name} tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted'
        SQL
      end

      def repeating_field_table(table, main_table)
        <<~SQL
          select tbl.*
          from #{table} tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted'
          inner join #{main_table} mt on tbl.id = mt.id
          where tbl.item is not null
        SQL
      end

      def addtl_fields_table(table, main_table)
        <<~SQL
          select tbl.*
          from #{table} tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted'
          inner join #{main_table} mt on tbl.id = mt.id
        SQL
      end

      def group_table(table)
        <<~SQL
          select
          phier.name as parentcsid,
          hier.pos,
          tbl.*
          from #{table} tbl
          inner join hierarchy hier on tbl.id = hier.id
          inner join misc on misc.id = hier.parentid and
            misc.lifecyclestate != 'deleted'
          inner join hierarchy phier on phier.id = hier.parentid
        SQL
      end
    end
  end
end
