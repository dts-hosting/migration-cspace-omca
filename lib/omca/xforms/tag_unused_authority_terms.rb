# frozen_string_literal: true

module Omca
  module Xforms
    class TagUnusedAuthorityTerms
      # Mode is added to implement keeping all location and taxon fields,
      #   regardless of usage status, but to also be able to re-run true
      #   unused term reports if needed going forward
      def initialize(rectype:, mode: :fix)
        @rectype = rectype
        @mode = mode
        @target = Omca::Authorities.used_tag_field
        @lookup = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: Omca.auth_uniq_usages, lookup_on: :vocab
        )
      end

      def process(row)
        return process_fix(row) if mode == :fix

        process_actual(row)
      end

      private

      attr_reader :rectype, :mode, :target, :lookup

      def process_fix(row)
        return all_yes(row) if %w[location taxon].include?(rectype)

        process_actual(row)
      end

      def all_yes(row)
        row[target] = "y"
        row
      end

      def process_actual(row)
        row[target] = if used?(row)
          "y"
        else
          "n"
        end

        row
      end

      def used?(row)
        used_terms = lookup[row[:authority]]
        true if used_terms.find { |t| t[:termid] == row[:shortidentifier] }
      end
    end
  end
end
