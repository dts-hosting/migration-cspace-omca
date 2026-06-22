# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      module UsagesFinal
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: %i[
                authorities__usages
                non_refname_auth__usage_merge
              ],
              destination: :non_refname_auth__usages_final
            },
            transformer: [
              Omca::Authorities.add_non_refname_index,
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::Fields, fields: :nonrefnameindex
          end
        end
      end
    end
  end
end
