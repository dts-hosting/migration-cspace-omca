# frozen_string_literal: true

module Omca
  module Db
    module Queries
      module_function

      def main_table(table_name)
        return main_authority_table(table_name) if Omca::Mappers.authority?(
          Omca::Mappings::Db.rectype_for_table(table_name)
        )

        <<~SQL
          select
          hier.name AS csid,
          tbl.*
          from #{table_name} tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted'
          inner join hierarchy hier on tbl.id = hier.id
        SQL
      end

      def main_authority_table(table_name)
        rectype = Omca::Mappings::Db.rectype_for_table(table_name)
        authtable = Omca::Mappers.auth_table_for(rectype)

        <<~SQL
          select
          hier.name AS csid,
          atbl.shortidentifier as authority,
          tbl.*
          from #{table_name} tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted'
          inner join hierarchy hier on tbl.id = hier.id
          inner join hierarchy ahier on ahier.name = tbl.inauthority
          inner join #{authtable} atbl on ahier.id = atbl.id
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
        return group_authority_table(table) if Omca::Mappers.authority?(
          Omca::Mappings::Db.rectype_for_table(table)
        )

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

      def group_authority_table(table)
        rectype = Omca::Mappings::Db.rectype_for_table(table)
        maintable = Omca::Mappings::Db.main_tables_by_rectype[rectype]
        authtable = Omca::Mappers.auth_table_for(rectype)

        <<~SQL
          select
          phier.name as parentcsid,
          auth.shortidentifier as authority,
          hier.pos,
          tbl.*
          from #{table} tbl
          inner join hierarchy hier on tbl.id = hier.id
          inner join misc on misc.id = hier.parentid and
            misc.lifecyclestate != 'deleted'
          inner join hierarchy phier on phier.id = hier.parentid
          inner join #{maintable} pcommon on phier.id = pcommon.id
          inner join hierarchy ahier on ahier.name = pcommon.inauthority
          inner join #{authtable} auth on auth.id = ahier.id
          order by phier.name, hier.pos
        SQL
      end

      def repeatable_in_group_table(table)
        <<~SQL
          select
          rechier.name as recordcsid,
          rechier.id as recordid,
          ghier.id as groupid,
          tbl.*
          from #{table} tbl
          inner join hierarchy ghier on tbl.id = ghier.id
          inner join hierarchy rechier on ghier.parentid = rechier.id
          inner join misc on rechier.id = misc.id and
            misc.lifecyclestate != 'deleted'
          where tbl.item is not null
          order by tbl.id, tbl.pos
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

      def top_level_structured_dates
        <<~SQL
          (
          select
          'structureddategroup' as dbtable,
          substring(
                      dhier.name for (position(':' in dhier.name) - 1)
                    ) as main_table,
          substring(
                      dhier.name from (position(':' in dhier.name) + 1)
                    ) as primarytype,
          rhier.name as parentcsid,
          dhier.pos,
          tbl.*
          from structureddategroup tbl
          inner join hierarchy dhier on dhier.id = tbl.id
          inner join hierarchy rhier on dhier.parentid = rhier.id
          inner join misc on rhier.id = misc.id and
            misc.lifecyclestate != 'deleted'
          where position(':' in dhier.name) > 0
          ) union (
          select
          'dategroup' as dbtable,
          substring(
                      dhier.name for (position(':' in dhier.name) - 1)
                    ) as main_table,
          substring(
                      dhier.name from (position(':' in dhier.name) + 1)
                    ) as primarytype,
          rhier.name as parentcsid,
          dhier.pos,
          tbl.*
          from dategroup tbl
          inner join hierarchy dhier on dhier.id = tbl.id
          inner join hierarchy rhier on dhier.parentid = rhier.id
          inner join misc on rhier.id = misc.id and
            misc.lifecyclestate != 'deleted'
          where position(':' in dhier.name) > 0
          )
        SQL
      end

      def nested_structured_dates
        <<~SQL
          (
          select
          'structureddategroup' as dbtable,
          substring(
            dghier.name for (position(':' in dghier.name) - 1)
          ) as main_table,
          dghier.primarytype,
          rhier.name as parentcsid,
          dghier.id as groupid,
          tbl.*
          from structureddategroup tbl
          inner join hierarchy dhier on dhier.id = tbl.id
          inner join hierarchy dghier on dhier.parentid = dghier.id
          inner join hierarchy rhier on dghier.parentid = rhier.id
          inner join misc on misc.id = rhier.id and
            misc.lifecyclestate != 'deleted'
          where position(':' in dghier.name) > 0
          ) union (
          select
          'dategroup' as dbtable,
          substring(
            dghier.name for (position(':' in dghier.name) - 1)
          ) as main_table,
          dghier.primarytype,
          rhier.name as parentcsid,
          dghier.id as groupid,
          tbl.*
          from dategroup tbl
          inner join hierarchy dhier on dhier.id = tbl.id
          inner join hierarchy dghier on dhier.parentid = dghier.id
          inner join hierarchy rhier on dghier.parentid = rhier.id
          inner join misc on misc.id = rhier.id and
            misc.lifecyclestate != 'deleted'
          where position(':' in dghier.name) > 0
          )
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

      def blobs
        <<~SQL
          with media as (
          select
          'media' as mediatype,
          mch.name as mediacsid,
          mc.blobcsid
          from media_common mc
          inner join misc on mc.id = misc.id and
            misc.lifecyclestate != 'deleted'
          inner join hierarchy mch on mch.id = mc.id

          union

          select
          'restrictedmedia' as mediatype,
          rmch.name as mediacsid,
          rmc.blobcsid
          from restrictedmedia_common rmc
          inner join misc on rmc.id = misc.id and
            misc.lifecyclestate != 'deleted'
          inner join hierarchy rmch on rmch.id = rmc.id
          )

          select media.*, bc.*
          from media
          inner join hierarchy hier on media.blobcsid = hier.name
          inner join blobs_common bc on hier.id = bc.id
          order by mediacsid
        SQL
      end
    end
  end
end
