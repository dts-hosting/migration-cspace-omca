# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      # Converts a single value from a non-group table to a repeatable field
      #   table. Can also be used to map from a single-value field to a
      #   repeatable field group table IF only one field is being mapped into
      #   the repeatable field group table.
      class SvFieldToRepeatableFieldTable
        # @param fieldmap [Hash] for renaming the field
        def initialize(fieldmap:)
          @renamer = Rename::Fields.new(
            fieldmap: fieldmap,
            suppress_missing_key_warnings: true
          )
          @deleter = Delete::FieldsExcept.new(
            fields: %i[recordcsid id] + fieldmap.values
          )
          @filter = FilterRows::FieldPopulated.new(
            action: :keep,
            field: fieldmap.values.first
          )
          @positioner = Merge::ConstantValue.new(
            target: :pos,
            value: "0"
          )
        end

        def process(row)
          renamer.process(row)
          deleter.process(row)
          filter.process(row)
          positioner.process(row)

          row
        end

        private

        attr_reader :renamer, :deleter, :filter, :positioner
      end
    end
  end
end
