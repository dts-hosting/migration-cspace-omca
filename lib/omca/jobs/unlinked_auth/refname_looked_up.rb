# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module RefnameLookedUp
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__refname_lookup,
              destination: :unlinked_auth__refname_looked_up
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
          end
        end
      end
    end
  end
end
