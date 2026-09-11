# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildPartiesinvolvedgroup
        def initialize
          @renamer = Rename::Fields.new(
            fieldmap: {
              contact: :involvedparty,
              contactrole: :involvedrole,
              viewername: :involvedparty,
              viewerrole: :involvedrole
            },
            suppress_missing_key_warnings: true
          )
          @deleter = Delete::FieldsExcept.new(
            fields: %i[recordcsid rectype pos id involvedparty involvedrole]
          )
          @replacer = Clean::RegexpFindReplaceFieldVals.new(
            fields: :rectype,
            find: /^collectionobject$/,
            replace: "consultation"
          )
        end

        def process(row)
          renamer.process(row)
          deleter.process(row)
          replacer.process(row)

          row
        end

        private

        attr_reader :renamer, :deleter, :replacer
      end
    end
  end
end
