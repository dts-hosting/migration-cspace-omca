# frozen_string_literal: true

module Omca
  module Xforms
    # Does nothing when record ID is present in :field; supplies a
    #   value consisting of the prefix, followed by incrementing
    #   number
    class AddMissingRecordId
      # @param idfield [Symbol] name of field containing human-readable
      #   record ids
      # @param prefix [String] id value to be provided, except for the
      #   incrementing digit(s), which will be appended to the end of this
      #   String
      def initialize(idfield:, prefix:)
        @idfield = idfield
        @prefix = prefix
        @counter = 0
      end

      def process(row)
        id = row[idfield]
        return row unless id.blank?

        add_id(row)
        row
      end

      private

      attr_reader :idfield, :prefix, :counter

      def add_id(row)
        @counter += 1

        row[idfield] = "#{prefix}#{counter}"
      end
    end
  end
end
