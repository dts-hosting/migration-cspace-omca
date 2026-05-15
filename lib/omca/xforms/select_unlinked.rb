# frozen_string_literal: true

module Omca
  module Xforms
    class SelectUnlinked
      def initialize(lookup:)
        @lookup = lookup
      end

      def process(row)
        idx = row[:index]
        return unless lookup.key?(idx)

        row
      end

      private

      attr_reader :lookup
    end
  end
end
