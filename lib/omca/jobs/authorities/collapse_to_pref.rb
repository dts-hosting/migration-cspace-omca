# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module CollapseToPref
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_uniq_usages,
              destination: :authorities__collapse_to_pref
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::AddPrefAuthData
            transform Clean::EnsureConsistentFields
          end
        end
      end
    end
  end
end
