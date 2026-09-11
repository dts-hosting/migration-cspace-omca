# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class AcquisitionsOmcaAnonymous
        def initialize(lookup:)
          @anon = lookup.values
            .flatten
            .reject { |r| r[:anonymous].blank? || r[:anonymous] == "f" }
          @rows = []
        end

        def process(row)
          rows << row

          nil
        end

        def close
          anon.each { |row| yield prep_anon(row) }
          rows.each { |row| yield row }
        end

        private

        attr_reader :anon, :rows

        def prep_anon(row)
          {
            recordcsid: row[:recordcsid],
            id: row[:id],
            pos: -1,
            item: row[:anonymous]
          }
        end
      end
    end
  end
end
