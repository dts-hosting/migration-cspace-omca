# frozen_string_literal: true

module Omca
  module Xforms
    class MergeRepeatableField
      def initialize(lookup:, target:)
        @lookup = lookup
        @target = target
      end

      def process(row)
        to_merge = lookup[row[:recordcsid]]
        unless to_merge
          row[target] = nil
          return row
        end

        row[target] = to_merge.sort_by { |tm| tm[:pos].to_i }
          .map { |tm| tm[:item] }
          .uniq
          .join(Omca.delim)
        row
      end

      private

      attr_reader :lookup, :target
    end
  end
end
