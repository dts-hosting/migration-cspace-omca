# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class MergeArtHistoryScienceRespdepts
        POS_VALS = {
          art: 20,
          history: 30,
          science: 40
        }

        def initialize(lookup:)
          @refs = lookup.values.flatten.reject do |r|
            [r[:art], r[:history], r[:science]].all?(&:blank?)
          end
          @records = {}
          @origrows = []
        end

        def process(row)
          records[row[:recordcsid]] = [] unless records.key?(row[:recordcsid])
          records[row[:recordcsid]] << row[:item].downcase.to_sym
          origrows << row

          nil
        end

        def close
          origrows.each { |row| yield row }

          refs.each do |ref|
            vals = records[ref[:recordcsid]]

            %i[art history science].each do |field|
              next if ref[field].blank?

              unless vals
                yield new_row(ref, field)
                next
              end

              next if vals.include?(field)

              yield new_row(ref, field)
            end
          end
        end

        def new_row(ref, field)
          {
            recordcsid: ref[:recordcsid],
            id: ref[:id],
            pos: POS_VALS[field],
            item: field.to_s.capitalize
          }
        end

        private

        attr_reader :refs, :records, :origrows
      end
    end
  end
end
