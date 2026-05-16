# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UnlinkedUsagesBase
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_usages,
              destination: :authorities__unlinked_usages_base,
              lookup: {jobkey: :authorities__unlinked_uniq_usages,
                       lookup_on: :index}
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::ReportUnlinked,
              lookup: authorities__unlinked_uniq_usages
          end
        end
      end
    end
  end
end
