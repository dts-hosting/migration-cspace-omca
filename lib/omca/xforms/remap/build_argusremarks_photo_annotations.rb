# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildArgusremarksPhotoAnnotations
        def initialize
          @rows = []
          @getter = Kiba::Extend::Transforms::Helpers::FieldValueGetter.new(
            fields: %i[argusremarks item]
          )
        end

        def process(row)
          rows << row

          nil
        end

        def close
          rows.group_by { |row| row[:recordcsid] }.values.each do |recrows|
            recrows.map.with_index { |row, idx| get_output_row(row, idx) }
              .flatten
              .compact
              .each { |row| yield row }
          end

          nil
        end

        private

        attr_reader :rows, :getter

        def get_output_row(row, pos)
          vals = getter.call(row)
          return if vals.empty?

          {
            recordcsid: row[:recordcsid],
            id: row[:id],
            pos: pos,
            annotationtype: type(vals.keys.first),
            annotationnote: vals.values.first
          }
        end

        def type(field)
          case field
          when :argusremarks then "Argus remark"
          when :item then "photography note"
          end
        end
      end
    end
  end
end
