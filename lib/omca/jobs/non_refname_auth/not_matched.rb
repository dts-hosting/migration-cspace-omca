# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      module NotMatched
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__refname_lookup,
              destination: :non_refname_auth__not_matched
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
