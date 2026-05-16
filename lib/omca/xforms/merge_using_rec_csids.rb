# frozen_string_literal: true

module Omca
  module Xforms
    class MergeUsingRecCsids
      def initialize
        @lookups = {}
      end

      def process(row)
        row[:rectype] = Omca::Mappings::Db.rectype_for_table(row[:table])
        lkup = get_lookup(row)
        using = lkup[row[:id]]&.first
        return row unless using

        row[:recordcsid] = using[:recordcsid]
        row
      end

      private

      attr_reader :lookups

      def get_lookup(row)
        table = row[:table]
        return lookups[table] if lookups.key?(table)

        lookups[table] = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :"#{row[:tabletype]}__#{table}",
          lookup_on: :id
        )
        lookups[table]
      end
    end
  end
end
