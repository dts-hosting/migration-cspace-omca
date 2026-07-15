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
        pref = pref_term(row)
        row[target] = if unused?(row)
          "#{pref} (UNUSED TERM)"
        else
          pref
        end
        row[:origpref] = pref
        row
      end

      private

      attr_reader :rectype, :target, :lookup

      def get_lookup(rectype)
        termtable = Omca::Mappers.term_table_for(rectype)
        Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :"nuke_bom_repeatable_field_group__#{termtable}",
          lookup_on: :recordcsid
        )
      end

      def pref_term(row)
        lookup[row[:recordcsid]].find { |t| t[:pos] == "0" }[:termdisplayname]
      end

      def unused?(row) = row[Omca::Authorities.used_tag_field] == "n"
    end
  end
end
