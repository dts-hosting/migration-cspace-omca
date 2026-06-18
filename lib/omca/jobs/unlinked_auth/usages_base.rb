# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module UsagesBase
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_usages,
              destination: :unlinked_auth__usages_base,
              lookup: {jobkey: :unlinked_auth__uniq_usages,
                       lookup_on: :index}
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::ReportUnlinked,
              lookup: unlinked_auth__uniq_usages
          end
        end
      end
    end
  end
end
