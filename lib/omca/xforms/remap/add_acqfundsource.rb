# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class AddAcqfundsource
        def initialize(lookup:)
          @afsrows = lookup.values.flatten
          @rows = []
        end

        def process(row)
          rows << row

          nil
        end

        def close
          afsrows.each { |row| yield row }
          rows.each { |row| yield row }
        end

        private

        attr_reader :afsrows, :rows
      end
    end
  end
end
