# frozen_string_literal: true

module Omca
  module Jobs
    module NewTable
      module Controlledcontentplaces
        module_function

        def desc = "Generate collectionobjects_common_controlledcontentplaces "\
          "based on assocplacegroup"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :fix_repeatable_field_group__assocplacegroup,
              destination: :new_table__controlledcontentplaces
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::Fields, fields: :assocplacenote
            transform Rename::Field,
              from: :assocplace,
              to: :item
          end
        end
      end
    end
  end
end
