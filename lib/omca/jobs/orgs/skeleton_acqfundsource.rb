# frozen_string_literal: true

module Omca
  module Jobs
    module Orgs
      module SkeletonAcqfundsource
        module_function

        def desc = "Prepare added org authority terms for skeleton load"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :orgs__orig_usages_acqfundsource,
              destination: :orgs__skeleton_acqfundsource
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::WithLambda,
              action: :keep,
              lambda: ->(row) { row[:termid].end_with?("-new") }
            transform Delete::FieldsExcept,
              fields: :form
            transform Deduplicate::Table,
              field: :form
            transform Rename::Field,
              from: :form,
              to: :termdisplayname
            transform Merge::ConstantValue,
              target: :organizationrecordtype,
              value: "acquisition funding source"
          end
        end
      end
    end
  end
end
