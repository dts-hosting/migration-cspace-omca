# frozen_string_literal: true

module Omca
  module Xforms
    class TagUnusedAuthorityTerms
      def initialize(rectype:)
        @rectype = rectype
        @target = Omca::Authorities.used_tag_field
        @lookup = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :authorities__fix_uniq_usages, lookup_on: :vocab
        )
      end

      def process(row)
        row[target] = if used?(row)
          "y"
        else
          "n"
        end

        row
      end

      private

      attr_reader :rectype, :target, :lookup

      def used?(row)
        used_terms = lookup[row[:authority]]
        true if used_terms.find { |t| t[:termid] == row[:shortidentifier] }
      end
    end
  end
end
