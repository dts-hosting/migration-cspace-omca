# frozen_string_literal: true

module Omca
  module Xforms
    class MergeRepeatableField
      def initialize(config:)
        @config = config
        @lookup = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :"fix_repeatable_field__#{config["source_db_table"]}",
          lookup_on: :recordcsid
        )
        @target = config["target_field"].to_sym
      end

      def process(row)
        to_merge = lookup[row[:recordcsid]]
        unless to_merge
          row[target] = nil
          return row
        end

        row[target] = to_merge.sort_by { |tm| tm[:pos].to_i }
          .map { |tm| tm[:item] }
          .join(Omca.delim)
        row
      end

      private

      attr_reader :config, :lookup, :target
    end
  end
end
