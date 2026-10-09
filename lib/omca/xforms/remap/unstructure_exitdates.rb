# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class UnstructureExitdates
        def initialize(lookup:)
          @merger = Merge::MultiRowLookup.new(
            lookup: lookup,
            keycolumn: :recordcsid,
            fieldmap: {exitdate: :datelatestscalarvalue}
          )
        end

        def process(row)
          merger.process(row)
          return row if row[:exitdate].blank?

          row[:exitdate] = row[:exitdate].sub(/^(\d{4}-\d{2}-\d{2}).*$/, '\1')
          row
        end

        private

        attr_reader :merger
      end
    end
  end
end
