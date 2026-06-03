# frozen_string_literal: true

module Omca
  module Xforms
    class BigAuthMerge
      def initialize(table:, tabletype:, rectype:, mergerows:)
        @table = table
        @tabletype = tabletype
        @rectype = rectype
        @lookup = mergerows.group_by { |r| r[:termid] }
      end

      def process(row)
        if tabletype == "main"
          merge_ingestid(row)
        elsif table == Omca::Mappers.term_table_for(rectype)
          binding.pry
        end

        row
      end

      private

      attr_reader :table, :tabletype, :rectype, :lookup

      def merge_ingestid(row)
        return unless lookup.key?(row[:shortidentifier])

        mergerow = lookup[row[:shortidentifier]].first
        row[Omca.ingestid_field] = mergerow[:new_form]
      end
    end
  end
end
