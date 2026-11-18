# frozen_string_literal: true

module Omca
  module Jobs
    module Orgs
      module MainAcqfundsource
        module_function

        def desc = "Prepare added org authority terms for merge into "\
          "organizations_common"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :orgs__orig_usages_acqfundsource,
              destination: :orgs__main_acqfundsource
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::WithLambda,
              action: :keep,
              lambda: ->(row) { row[:termid].end_with?("-new") }
            transform Deduplicate::Table,
              field: :form
            transform Delete::Fields,
              fields: %i[tabletype table field pos authority]
            transform Rename::Fields, fieldmap: {
              vocab: :authority,
              termid: :shortidentifier,
              form: :ingestid
            }
            transform Copy::Field,
              from: :ingestid,
              to: :origpref
            transform Copy::Field,
              from: :id,
              to: :recordcsid
            transform Merge::ConstantValue,
              target: :term_is_used,
              value: "y"
          end
        end
      end
    end
  end
end
