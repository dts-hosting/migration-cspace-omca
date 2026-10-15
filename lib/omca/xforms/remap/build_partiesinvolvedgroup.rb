# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildPartiesinvolvedgroup
        def initialize
          fieldmap = {
            contact: :involvedparty,
            contactrole: :involvedrole,
            viewername: :involvedparty,
            viewerrole: :involvedrole
          }
          @renamer = Rename::Fields.new(
            fieldmap: fieldmap,
            suppress_missing_key_warnings: true
          )
          @deleter = Delete::FieldsExcept.new(
            fields: %i[recordcsid rectype pos id] + fieldmap.values
          )
          @replacer = Clean::RegexpFindReplaceFieldVals.new(
            fields: :rectype,
            find: /^collectionobject$/,
            replace: "consultation"
          )
          @filter = FilterRows::AnyFieldsPopulated.new(
            action: :keep,
            fields: fieldmap.values
          )
        end

        def process(row)
          renamer.process(row)
          deleter.process(row)
          replacer.process(row)
          filter.process(row)

          row
        end

        private

        attr_reader :renamer, :deleter, :replacer, :filter
      end
    end
  end
end
