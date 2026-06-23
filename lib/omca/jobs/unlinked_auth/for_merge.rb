# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module ForMerge
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: %i[
                unlinked_auth__refname_looked_up
                unlinked_auth__refname_fcar_provided
              ],
              destination: :unlinked_auth__for_merge
            },
            transformer: [
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[index refname]
          end
        end
      end
    end
  end
end
