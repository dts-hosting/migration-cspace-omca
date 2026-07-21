# frozen_string_literal: true

module Omca
  module Xforms
    class AddSubgroup
      SG_META_FIELDS = %i[recordcsid rectype groupid grouptable
        pos id]

      def initialize(src:)
        @src = src
        @lookup = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: src,
          lookup_on: :groupid
        )
        @fields = lookup.first[1][0].keys - SG_META_FIELDS
      end

      def process(row)
        merges = lookup[row[:id]]
        unless merges
          fields.each { |field| row[field] = nil }
          return row
        end

        merges.sort_by! { |m| m[:pos].to_i }
        fields.each { |field| merge_field(row, field, merges) }

        row
      end

      private

      attr_reader :src, :lookup, :fields

      def merge_field(row, field, merges)
        vals = merges.map { |m| m[field].blank? ? "%NULLVALUE%" : m[field] }
          .join(Omca.sgdelim)
        row[field] = vals
      end
    end
  end
end
