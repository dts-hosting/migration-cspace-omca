# frozen_string_literal: true

module Omca
  module Xforms
    class AddAddtlFields
      META_FIELDS = %i[recordcsid id]

      def initialize(lookup:)
        @lookup = lookup
        @fields = lookup.first[1][0].keys - META_FIELDS
      end

      def process(row)
        merge_row = lookup[row[:recordcsid]]
        unless merge_row
          fields.each { |field| row[field] = nil }
          return row
        end

        fields.each { |field| merge_field(row, field, merge_row[0]) }

        row
      end

      private

      attr_reader :lookup, :fields

      def merge_field(row, field, merge_row) = row[field] = merge_row[field]
    end
  end
end
