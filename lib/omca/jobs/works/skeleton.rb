# frozen_string_literal: true

module Omca
  module Jobs
    module Works
      module Skeleton
        module_function

        def desc = "Prepare work authority terms for skeleton load"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :works__orig_usages,
              destination: :works__skeleton
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: :form
            transform Deduplicate::Table,
              field: :form
            transform Rename::Field,
              from: :form,
              to: :termdisplayname
            transform Merge::ConstantValue,
              target: :worktype,
              value: "collection"
          end
        end
      end
    end
  end
end
