# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module UniqUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__collapse_to_pref,
              destination: :unlinked_auth__uniq_usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :reject,
              field: :refname
            transform Delete::Fields,
              fields: %i[preferred_term csid refname]
          end
        end
      end
    end
  end
end
