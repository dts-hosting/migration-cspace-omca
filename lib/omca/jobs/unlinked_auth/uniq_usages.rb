# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module UniqUsages
        module_function

        def desc = "Deletes :authorities__add_pref_term_data rows with a "\
          "refname merged in from authority term table."

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__add_pref_term_data,
              destination: :unlinked_auth__uniq_usages
            },
            transformer: [
              xforms,
              Omca::Authorities.add_term_index
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :reject,
              field: :preftermrefname
            transform Delete::Fields,
              fields: %i[preftermcsid preftermrefname refname]
          end
        end
      end
    end
  end
end
