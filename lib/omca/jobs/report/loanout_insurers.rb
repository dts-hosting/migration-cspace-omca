# frozen_string_literal: true

module Omca
  module Jobs
    module Report
      module LoanoutInsurers
        module_function

        def job
          srcstr = "preprocess_repeatable_field__"\
            "loansout_omca_loanoutinsuranceinsurers"
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: srcstr.to_sym,
              destination: :report__loanout_insurers,
              lookup: {
                jobkey: :refname_csid_lookup__loanout,
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
              lookup: refname_csid_lookup__loanout,
              keycolumn: :oldcsid,
              fieldmap: {
                newcsid: :newcsid,
                loanoutnumber: :loanoutnumber
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
