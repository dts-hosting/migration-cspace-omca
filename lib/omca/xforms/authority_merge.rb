# frozen_string_literal: true

module Omca
  module Xforms
    class AuthorityMerge
      def initialize(lookup:)
        @lookup = lookup
      end

      def process(row)
        merges = lookup[row[:id]]
        return row unless merges

        merges.each do |mergedata|
          target = mergedata[:field].to_sym
          val = mergedata[:refname]
          row[target] = val
        end

        row
      end

      private

      attr_reader :lookup
    end
  end
end
