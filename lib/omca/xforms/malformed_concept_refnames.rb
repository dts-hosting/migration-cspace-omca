# frozen_string_literal: true

module Omca
  module Xforms
    class MalformedConceptRefnames
      def initialize
        @bad_domain_pattern = "urn:cspace:museumca.concept"
        @bad_item_pattern = Regexp.new('\)"item"name')
      end

      def process(row)
        refname = row[:refname]

        to_fix = [bad_domain(refname), bad_item(refname)].compact
        return row if to_fix.empty?

        to_fix.each { |fix| fix_row(fix, row) }

        row
      end

      private

      attr_reader :bad_domain_pattern, :bad_item_pattern

      def bad_domain(refname)
        :fix_bad_domain if refname.start_with?(bad_domain_pattern)
      end

      def bad_item(refname)
        :fix_bad_item if refname.match?(bad_item_pattern)
      end

      def fix_row(fix, row)
        newval = send(fix, row[:refname])
        Omca::Refname.add_parsed_detail(row, newval, sym: true)
      end

      def fix_bad_domain(val)
        good = "urn:cspace:museumca.org:concept"
        "#{good}#{val.delete_prefix(bad_domain_pattern)}"
      end

      def fix_bad_item(val)
        val.sub(bad_item_pattern, "):item:name")
      end
    end
  end
end
