# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UnlinkedUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_usages,
              destination: :authorities__unlinked_usages,
              lookup: {jobkey: :authorities__unlinked_uniq_usages,
                       lookup_on: :index}
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::SelectUnlinked,
              lookup: authorities__unlinked_uniq_usages
          end
        end
      end
    end
  end
end
