# frozen_string_literal: true

module Omca
  module Jobs
    module Report
      module LoaninInsurers
        module_function

        def job
          srcstr = "preprocess_repeatable_field__"\
            "loansin_omca_loanininsuranceinsurers"

          Kiba::Extend::Jobs::Job.new(
            files: {
              source: srcstr.to_sym,
              destination: :report__loanin_insurers,
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
            transform do |row|
              refname = row[:item]
              row[:insurer] = Omca::Refname.deurn(refname)
              row.delete(:item)
              row.delete(:id)
              row
            end
          end
        end
      end
    end
  end
end
