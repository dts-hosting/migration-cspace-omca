# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      module NotMatchedClientCleanup
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__final,
              destination: :non_refname_auth__not_matched_client_cleanup
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :reject,
              field: :refname
          end
        end
      end
    end
  end
end
