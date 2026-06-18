# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      module UniqUsages
        module_function

        def desc = "Write one row per used non-refname value in
        authority-controlled field, with count of usages."

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__usages,
              destination: :non_refname_auth__uniq_usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::UniqNonRefnameAuthUsages
          end
        end
      end
    end
  end
end
