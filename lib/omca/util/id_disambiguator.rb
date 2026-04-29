# frozen_string_literal: true

module Omca
  module Util
    class IdDisambiguator
      # @param rows [Array<Hash>]
      def initialize(rows)
        @rows = rows
        @num = 0
      end

      def call
        rows.map { |row| disambiguate(row) }
      end

      private

      attr_reader :rows, :num

      def disambiguate(row)
        @num += 1
        newval = "#{row[Omca.ingestid_field]} (duplicate #{num})"
        row[Omca.ingestid_field] = newval
        row
      end
    end
  end
end
