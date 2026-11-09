# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildTextualinscriptiongroup
        def initialize
          @getter = Kiba::Extend::Transforms::Helpers::FieldValueGetter.new(
            fields: %i[inscriptionomca signatureomca]
          )
        end

        def process(row)
          pos = 0
          vals = getter.call(row)
          return if vals.empty?

          base = {
            recordcsid: row[:recordcsid],
            id: row[:id]
          }

          if vals.key?(:inscriptionomca)
            yield ins_row(base, vals[:inscriptionomca], pos)
            pos += 1
          end

          if vals.key?(:signatureomca)
            yield sig_row(base, vals[:signatureomca], pos)
            pos + 1
          end
          nil
        end

        private

        attr_reader :getter

        def ins_row(base, val, pos)
          base.merge({
            inscriptioncontent: val,
            inscriptioncontenttype: nil,
            pos: pos
          })
        end

        def sig_row(base, val, pos)
          base.merge({
            inscriptioncontent: val,
            inscriptioncontenttype: "signature",
            pos: pos
          })
        end
      end
    end
  end
end
