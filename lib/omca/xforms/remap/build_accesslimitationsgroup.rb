# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildAccesslimitationsgroup
        def initialize
          fieldmap = {
            accessrestrictiondate: :requestdate,
            accessrestrictiondetails: :limitationdetails,
            accessrestrictionlevel: :limitationlevel,
            accessrestrictionrequestor: :requester,
            accessrestrictiontype: :limitationtype
          }
          @renamer = Rename::Fields.new(
            fieldmap: fieldmap,
            suppress_missing_key_warnings: true
          )
          @deleter = Delete::FieldsExcept.new(
            fields: %i[recordcsid rectype pos id] + fieldmap.values
          )
          @filter = FilterRows::AnyFieldsPopulated.new(
            action: :keep,
            fields: fieldmap.values
          )
        end

        def process(row)
          renamer.process(row)
          deleter.process(row)
          filter.process(row)

          row
        end

        private

        attr_reader :renamer, :deleter, :filter
      end
    end
  end
end
