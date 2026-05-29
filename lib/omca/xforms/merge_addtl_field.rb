# frozen_string_literal: true

module Omca
  module Xforms
    class MergeAddtlField
      def initialize(config:)
        @config = config
        @lookup = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :"fix_addtl_fields__#{config["source_db_table"]}",
          lookup_on: :recordcsid
        )
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
