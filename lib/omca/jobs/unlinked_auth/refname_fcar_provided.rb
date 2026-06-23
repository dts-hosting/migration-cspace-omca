# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module RefnameFcarProvided
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__final,
              destination: :unlinked_auth__refname_fcar_provided
            },
            transformer: [
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :refname
            transform Delete::Fields,
              fields: %i[prepfingerprint clean_fingerprint]
          end
        end
      end
    end
  end
end
