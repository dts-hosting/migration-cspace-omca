# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class AddDimensionnote
        def initialize(lookup:)
          @lookup = lookup
        end

        def process(row)
          row[:measuredpartnote] = nil
          matches = lookup[row[:id]].reject { |r| r[:dimensionnote].blank? }

          return row if matches.empty?

          row[:measuredpartnote] = matches.map do |r|
            [r[:dimension], r[:dimensionnote]].reject(&:blank?).join(": ")
          end.join("; ")

          row
        end

        private

        attr_reader :lookup
      end
    end
  end
end
