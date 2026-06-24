# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      module CollapsingUsageMerge
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__usages,
              destination: :big_auth__collapsing_usage_merge,
              lookup: {
                jobkey: :big_auth__collapsing,
                lookup_on: :index
              }
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Merge::MultiRowLookup,
              lookup: big_auth__collapsing,
              keycolumn: :index,
              fieldmap: {updatingto: :refname},
              delim: Omca.delim

            transform do |row|
              corr = row.delete(:updatingto)
              next row if corr.blank?

              row[:refname] = corr
              Omca::Refname.add_parsed_detail(row, corr, sym: true)
              row[:index] = [
                row[:authority], row[:vocab], row[:termid]
              ].join(" ")
              row
            end
          end
        end
      end
    end
  end
end
