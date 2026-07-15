# frozen_string_literal: true

module Omca
  module Xforms
    class AddPrefAuthData
      def initialize
        @lookups = {}
      end

      def process(row)
        row[:preftermrecordcsid] = nil
        row[:preftermrefname] = nil
        lkup = get_lookup(row)
        pref = lkup[row[:termid]]&.first
        return row unless pref

        row.merge({
          preftermrecordcsid: pref[:recordcsid],
          preftermrefname: pref[:refname]
        })
      end

      private

      attr_reader :lookups

      def get_lookup(row)
        auth = row[:authority]
        return lookups[auth] if lookups.key?(auth)

        rectype = Omca::Mappings::Db.rectype_for_table("#{auth}_common")
        table = Omca::Mappings::Db.main_tables_by_rectype[rectype]

        lookups[auth] = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :"nuke_bom_main__#{table}",
          lookup_on: :shortidentifier
        )
        lookups[auth]
      end
    end
  end
end
