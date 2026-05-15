# frozen_string_literal: true

module Omca
  module Xforms
    class AddPrefAuthData
      def initialize
        @lookups = {}
      end

      def process(row)
        lkup = get_lookup(row)
        pref = lkup[row[:termid]]&.first
        return row unless pref

        row.merge({
          preferred_term: pref[Omca.ingestid_field],
          csid: pref[:csid],
          refname: pref[:refname]
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
          jobkey: :"fix_main__#{table}",
          lookup_on: :shortidentifier
        )
        lookups[auth]
      end

      def pref_term(row)
        lookup[row[:csid]].find { |t| t[:pos] == "0" }[:termdisplayname]
      end

      def unused?(row) = row[Omca::Authorities.used_tag_field] == "n"
    end
  end
end
