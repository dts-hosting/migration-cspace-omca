# frozen_string_literal: true

module Omca
  module Xforms
    class AuthorityMerge
      def initialize(lookup:, field:)
        @lookup = lookup
        @field = field.to_sym
      end

      def process(row)
        merges = lookup[row[:id]]
        unless merges
          row[field] = nil
          return row
        end

        merges.each do |mergedata|
          target = mergedata[:field].to_sym
          val = mergedata[:refname]
          row[target] = val
        end

        row
      end

      private

      attr_reader :field, :lookup
    end
  end
end
