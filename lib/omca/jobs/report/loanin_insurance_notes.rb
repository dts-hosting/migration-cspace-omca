# frozen_string_literal: true

module Omca
  module Jobs
    module Report
      module LoaninInsuranceNotes
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :fix_addtl_fields__loansin_omca,
              destination: :report__loanin_insurance_notes,
              lookup: {
                jobkey: :refname_csid_lookup__loanin,
                lookup_on: :oldcsid
              }
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :loanininsurancenote
            transform Delete::FieldsExcept,
              fields: %i[recordcsid loanininsurancenote]

            transform Rename::Field,
              from: :recordcsid,
              to: :oldcsid
            transform Merge::MultiRowLookup,
              lookup: refname_csid_lookup__loanin,
              keycolumn: :oldcsid,
              fieldmap: {
                newcsid: :newcsid,
                loaninnumber: :loaninnumber
              }
          end
        end
      end
    end
  end
end
