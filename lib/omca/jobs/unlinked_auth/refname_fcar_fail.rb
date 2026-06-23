# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module RefnameFcarFail
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__final,
              destination: :unlinked_auth__refname_fcar_fail
            },
            transformer: [
              xforms
            ]
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
