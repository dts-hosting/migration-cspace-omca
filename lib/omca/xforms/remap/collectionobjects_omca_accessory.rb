# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class CollectionobjectsOmcaAccessory
        def initialize(lookup:)
          @acc = lookup.values
            .flatten
            .reject { |r| r[:accessory].blank? }
          @rows = []
        end

        def process(row)
          rows << row

          nil
        end

        def close
          acc.each { |row| yield prep_acc(row) }
          rows.each { |row| yield row }
        end

        private

        attr_reader :acc, :rows

        def prep_acc(row)
          {
            recordcsid: row[:recordcsid],
            id: row[:id],
            pos: 21,
            objectcomponentname: "accessory",
            objectcomponentinformation: row[:accessory]
          }
        end
      end
    end
  end
end
