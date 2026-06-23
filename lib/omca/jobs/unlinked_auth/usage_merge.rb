# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module UsageMerge
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_usages,
              destination: :unlinked_auth__usages,
              lookup: [{
                jobkey: :unlinked_auth__for_merge,
                lookup_on: :index
              },
                {
                  jobkey: :unlinked_auth__refname_fcar_fail,
                  lookup_on: :index
                }]
            },
            transformer: [
              Omca::Authorities.add_term_index,
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Merge::MultiRowLookup,
              lookup: unlinked_auth__refname_fcar_fail,
              keycolumn: :index,
              fieldmap: {unlinked: :index},
              delim: Omca.delim
            transform Merge::MultiRowLookup,
              lookup: unlinked_auth__for_merge,
              keycolumn: :index,
              fieldmap: {corrected: :refname},
              delim: Omca.delim
            transform FilterRows::WithLambda,
              action: :reject,
              lambda: ->(row) do
                !row[:unlinked].blank? && row[:corrected].blank?
              end

            transform do |row|
              row.delete(:unlinked)
              corr = row.delete(:corrected)
              next row if corr.blank?

              row[:refname] = corr
              Omca::Refname.add_parsed_detail(row, corr, sym: true)
              row
            end
          end
        end
      end
    end
  end
end
