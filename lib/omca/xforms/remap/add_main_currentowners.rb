# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class AddMainCurrentowners
        def initialize(lookup:)
          @mainrows = lookup.values.flatten
          @rows = []
          @deleter = Delete::FieldsExcept.new(
            fields: %i[recordcsid id currentowner]
          )
          @renamer = Rename::Field.new(
            from: :currentowner,
            to: :item
          )
          @posinserter = Merge::ConstantValue.new(
            target: :pos,
            value: "-1"
          )
        end

        def process(row)
          rows << row

          nil
        end

        def close
          mainrows.each do |row|
            next if row[:currentowner].blank?

            yield transformed(row)
          end
          rows.each { |row| yield row }
        end

        private

        attr_reader :mainrows, :rows, :deleter, :renamer, :posinserter

        def transformed(row)
          deleter.process(row)
          renamer.process(row)
          posinserter.process(row)
          row
        end
      end
    end
  end
end
