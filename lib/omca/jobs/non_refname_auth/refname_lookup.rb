# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      module RefnameLookup
        module_function

        def desc = "Look for authority record matching non-refname "\
        "values in the appropriate authority vocabularies for the fields "\
        "where the values are used. Writes out file that can be used as "\
        "supplied lookup for fixes made to the tables where these values "\
        "occur"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__uniq_usages,
              destination: :non_refname_auth__refname_lookup
            },
            transformer: [
              xforms,
              Omca::Authorities.add_non_refname_index
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::NonRefnameAuthRefnameLookup
          end
        end
      end
    end
  end
end
