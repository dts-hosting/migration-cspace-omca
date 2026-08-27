# frozen_string_literal: true

module Omca
  module Xforms
    class RemapEthcultureMain
      def initialize(lookup:)
        @lookup = lookup.transform_keys do |k|
          k.delete_suffix("ethculture")
        end
        @rows = []
      end

      def process(row)
        unless row[:authority] == "concept" &&
            lookup.key?(row[:shortidentifier])
          rows << row
          return
        end

        rows << row

        lrow = lookup[row[:shortidentifier]].first
        newrow = row.dup
        newrow[:authority] = "ethculture"
        newrow[:refname] = lrow[:refname]
        newrow[:shortidentifier] = lrow[:termid]
        newrow[:recordcsid] = "#{row[:recordcsid]}ethculture"
        rows << newrow

        nil
      end

      def close = rows.each { |r| yield r }

      private

      attr_reader :lookup, :rows
    end
  end
end
