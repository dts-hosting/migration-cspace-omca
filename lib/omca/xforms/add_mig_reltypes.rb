# frozen_string_literal: true

module Omca
  module Xforms
    class AddMigReltypes
      def initialize
        @rows = []
      end

      def process(row)
        rows << row

        nil
      end

      def close
        add_nonhier_object_consultation
        rows.each { |row| yield row }
      end

      private

      attr_reader :rows

      def add_nonhier_object_consultation
        rows << {
          reltype: "nonhier",
          source0: "collectionobject_consultation",
          source1: nil,
          target0: "collectionobject",
          target1: "consultation"
        }
      end
    end
  end
end
