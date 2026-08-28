# frozen_string_literal: true

module Omca
  module Jobs
    module Assocplace
      module Remapped
        module_function

        def desc = "Remap collectionobjects_common.assocPlace usages to "\
          "collectionobjects_common.controlledContentPlace"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :assocplace__usages,
              destination: :assocplace__remapped
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::Fields, fields: %i[table field]
            transform Merge::ConstantValues,
              constantmap: {
                table: "collectionobjects_common_controlledcontentplaces",
                field: "item"
              }
          end
        end
      end
    end
  end
end
