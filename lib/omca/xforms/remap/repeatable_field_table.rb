# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      # Used to remap an existing repeatable field table to a new one
      class RepeatableFieldTable
        def initialize
          @deleter = Delete::FieldsExcept.new(
            fields: %i[recordcsid id item pos]
          )
          @filter = FilterRows::FieldPopulated.new(
            action: :keep,
            field: :item
          )
        end

        def process(row)
          deleter.process(row)
          filter.process(row)

          row
        end

        private

        attr_reader :deleter, :filter
      end
    end
  end
end
