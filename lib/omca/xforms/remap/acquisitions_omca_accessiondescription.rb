# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class AcquisitionsOmcaAccessiondescription
        def initialize(lookup:)
          @merger = Merge::MultiRowLookup.new(
            lookup: lookup,
            keycolumn: :recordcsid,
            fieldmap: {acquisitiondescription: :accessiondescription}
          )
        end

        def process(row)
          merger.process(row)

          row
        end

        private

        attr_reader :merger
      end
    end
  end
end
