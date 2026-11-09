# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildAddressNotes
        def initialize
          @getter = Kiba::Extend::Transforms::Helpers::FieldValueGetter.new(
            fields: %i[
              addresscountryomca
              addressmunicipalityomca
              addressplace1omca
              addressplace2omca
              addresspostcodeomca
              addressstateorprovinceomca
              addresstypeomca
            ]
          )
        end

        def process(row)
          note = row[:addressnoteomca]
          return if note.blank?

          addressnote = if contains_address?(row)
            "Note on #{addrid(row)}: #{note}"
          else
            note
          end
          {
            recordcsid: row[:recordcsid],
            id: row[:id],
            pos: row[:pos],
            note: addressnote
          }
        end

        private

        attr_reader :getter

        def contains_address?(row) = !getter.call(row).empty?

        def addrid(row) = [
          row[:addresstypeomca],
          "address",
          brief(row)
        ].reject(&:blank?)
          .join(" ")

        def brief(row)
          vals = [
            row[:addressplace1omca], row[:addressplace2omca]
          ].reject(&:blank?)
          return if vals.empty?

          "(#{vals.join(" / ")})"
        end
      end
    end
  end
end
