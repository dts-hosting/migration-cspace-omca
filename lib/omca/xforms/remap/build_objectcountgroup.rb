# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildObjectcountgroup
        def initialize
          @rows = []
          @getter = Kiba::Extend::Transforms::Helpers::FieldValueGetter.new(
            fields: %i[arguscount numberofobjects]
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

          field = vals.keys.first
          val = vals.values.first
          base = {
            recordcsid: row[:recordcsid],
            id: row[:id],
            pos: pos
          }

          base[:objectcounttype] = case field
          when :arguscount then "Argus count"
          when :numberofobjects then nil
          end
          base[:objectcountnote] = case field
          when :arguscount then val
          when :numberofobjects then nil
          end
          base[:objectcountunit] = case field
          when :arguscount then nil
          when :numberofobjects then "object"
          end
          base[:objectcount] = case field
          when :arguscount then nil
          when :numberofobjects then val
          end

          base
        end
      end
    end
  end
end
