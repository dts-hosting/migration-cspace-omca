# frozen_string_literal: true

module Omca
  module Db
    module Queries
      module_function

      def main_table(table_name)
        <<~SQL
          select
          hier.name AS csid,
          tbl.*
          from #{table_name} tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted',
          inner join hierarchy hier on tbl.id = hier.id
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
          order by tbl.id, tbl.pos
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
          order by phier.name, hier.pos
        SQL
      end

      def subgroup_table(table)
        <<~SQL
          SELECT phier.name as recordcsid,
          ghier.id as groupid,
          sghier.pos,
          tbl.*
          FROM #{table} tbl
          inner join hierarchy sghier on tbl.id = sghier.id
          inner join hierarchy ghier on ghier.id = sghier.parentid
          inner join hierarchy phier on phier.id = ghier.parentid
          inner join misc on misc.id = phier.id and
            misc.lifecyclestate != 'deleted'
          order by phier.name, sghier.pos
        SQL
      end

      def contacts
        <<~SQL
          select
          chier.name AS contactcsid,
          ahier.name AS termcsid,
          cc.uri AS termuri,
          ahier.id AS term_db_id,
          tbl.*
          from contacts_common tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted'
          inner join hierarchy chier on tbl.id = chier.id
          inner join hierarchy ahier on tbl.initem = ahier.name
          inner join collectionspace_core cc on cc.id = ahier.id
        SQL
      end
    end
  end
end
