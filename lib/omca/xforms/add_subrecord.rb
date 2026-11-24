# frozen_string_literal: true

module Omca
  module Xforms
    class AddSubrecord
      META_FIELDS = %i[recordcsid termcsid id]

      def initialize(lookup:)
        @lookup = lookup
        @fields = lookup.first[1][0].keys - META_FIELDS
      end

      def process(row)
        mergerow = lookup[row[:recordcsid]]

        unless mergerow
          fields.each { |field| row[field] = nil }
          return row
        end

        fields.each { |field| merge_field(row, field, mergerow[0]) }

        row
      end

      private

      attr_reader :lookup, :fields

      def merge_field(row, field, mergerow)
        row[field] = mergerow[field]
      end
    end
  end
end
