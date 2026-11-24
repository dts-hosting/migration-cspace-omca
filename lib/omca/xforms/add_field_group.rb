# frozen_string_literal: true

module Omca
  module Xforms
    class AddFieldGroup
      META_FIELDS = %i[recordcsid rectype pos id]

      def initialize(lookup:)
        @lookup = lookup
        @fields = lookup.first[1][0].keys - META_FIELDS
      end

      def process(row)
        merges = lookup[row[:recordcsid]]
        unless merges
          fields.each { |field| row[field] = nil }
          return row
        end

        merges.sort_by! { |m| m[:pos].to_i }
        fields.each { |field| merge_field(row, field, merges) }

        row
      end

      private

      attr_reader :lookup, :fields

      def merge_field(row, field, merges)
        vals = merges.map { |m| m[field].blank? ? "%NULLVALUE%" : m[field] }
          .join(Omca.delim)
        row[field] = vals
      end
    end
  end
end
