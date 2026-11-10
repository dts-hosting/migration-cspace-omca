# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class AddDistinguishingfeatureComments
        def initialize(lookup:)
          @corows = lookup.values
            .flatten
            .reject { |r| r[:distinguishingfeatures].blank? }
          @rows = []
        end

        def process(row)
          rows << row

          nil
        end

        def close
          corows.each do |row|
            result = {
              recordcsid: row[:recordcsid],
              id: row[:id],
              pos: "50",
              item: row[:distinguishingfeatures]
            }
            yield result
          end

          rows.each { |row| yield row }
        end

        private

        attr_reader :corows, :rows
      end
    end
  end
end
