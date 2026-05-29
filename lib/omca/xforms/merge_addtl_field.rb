# frozen_string_literal: true

module Omca
  module Xforms
    class MergeAddtlField
      include MergeLookupable

      def initialize(config:)
        @config = config
        @lookup = get_lookup(config["source_db_table"])
        @source = config["db_field"].to_sym
        @target = config["target_field"].to_sym
      end

      def process(row)
        to_merge = lookup[row[:recordcsid]]
        unless to_merge
          row[target] = nil
          return row
        end

        row[target] = to_merge.first[source]
        row
      end

      private

      attr_reader :config, :lookup, :source, :target
    end
  end
end
