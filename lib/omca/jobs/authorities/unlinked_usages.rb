# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UnlinkedUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__unlinked_usages_base,
              destination: :authorities__unlinked_usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::MergeUsingRecCsids
            transform Clean::EnsureConsistentFields
            transform Delete::Fields,
              fields: %i[id index]
            transform Rename::Fields, fieldmap: {
              refname: :usage_refname,
              form: :used_form
            }
          end
        end
      end
    end
  end
end
