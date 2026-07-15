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
        add_nonhier_insurance_loan("in")
        add_nonhier_insurance_loan("out")
        rows.each { |row| yield row }
      end

      private

      attr_reader :rows

      def add_nonhier_object_consultation
        rows << {
          reltype: "nonhier",
          source0: nil,
          source1: nil,
          target0: "collectionobject",
          target1: "consultation"
        }
      end

      def add_nonhier_insurance_loan(type)
        rows << {
          reltype: "nonhier",
          source0: nil,
          source1: nil,
          target0: "insurance",
          target1: "loan#{type}"
        }
      end
    end
  end
end
