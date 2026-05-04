# frozen_string_literal: true

module Omca
  module Xforms
    class MergePreferredTerm
      def initialize(rectype:)
        @rectype = rectype
        @target = Omca.ingestid_field
        @lookup = get_lookup(rectype)
      end

      def process(row)
        row[target] = pref_term(row)

        row
      end

      private

      attr_reader :rectype, :target, :lookup

      def get_lookup(rectype)
        termtable = Omca::Mappers.term_table_for(rectype)
        Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :"field_groups__#{termtable}",
          lookup_on: :parentcsid
        )
      end

      def pref_term(row)
        lookup[row[:csid]].find { |t| t[:pos] == "0" }[:termdisplayname]
      end
    end
  end
end
