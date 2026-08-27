# frozen_string_literal: true

module Omca
  module Xforms
    class RemapEthcultureTerm
      def initialize(lookup:)
        @lookup = lookup["ethculture"].map do |r|
          r[:recordcsid] = r[:recordcsid].delete_suffix("ethculture")
          r
        end
        @rows = []
      end

      def process(row)
        rows << row
        mainrow = lookup.find { |r| r[:recordcsid] == row[:recordcsid] }
        return unless mainrow

        newrow = row.dup
        newrow[:recordcsid] = "#{newrow[:recordcsid]}ethculture"
        if row.key?(:authority)
          newrow[:authority] = "ethculture"
        end
        if row.key?(:shortidentifier)
          newrow[:shortidentifier] = mainrow[:shortidentifier]
        end
        rows << newrow

        nil
      end

      def close = rows.each { |r| yield r }

      private

      attr_reader :lookup, :rows
    end
  end
end
