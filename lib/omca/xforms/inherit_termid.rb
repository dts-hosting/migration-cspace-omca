# frozen_string_literal: true

module Omca
  module Xforms
    class InheritTermid
      def initialize(rectype:)
        @rectype = rectype
        main_table = Omca::Mappings::Db.main_tables_by_rectype[rectype]
        @lookup = Kiba::Extend::Utils::Lookup.from_job(
          jobkey: :"preprocess_main__#{main_table}", lookup_on: :recordcsid
        )
        @target = :shortidentifier
      end

      def process(row)
        parent = lookup[row[:recordcsid]]&.first

        row[target] = if parent
          parent[target]
        else
          "no parent record"
        end

        row
      end

      private

      attr_reader :rectype, :target, :lookup
    end
  end
end
