# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module RefnameLookup
        module_function

        def desc = "Look for authority record matching unlinked auth "\
        "forms in the authority vocabularies specified in the unlinked  "\
        "refname. Writes out file that can be used as "\
        "supplied lookup for fixes made to the tables where these values "\
        "occur"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__uniq_usages_explode,
              destination: :unlinked_auth__refname_lookup
            },
            transformer: [
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::UnlinkedAuthRefnameLookup
          end
        end
      end
    end
  end
end
