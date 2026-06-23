# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module RefnameNoMatch
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__refname_lookup,
              destination: :unlinked_auth__refname_no_match
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
            transform Fingerprint::Add,
              fields: %i[index form],
              target: :prepfingerprint
          end
        end
      end
    end
  end
end
