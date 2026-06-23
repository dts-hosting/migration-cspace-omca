# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module AddPrefTermData
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_uniq_usages,
              destination: :authorities__add_pref_term_data
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::AddPrefAuthData
          end
        end
      end
    end
  end
end
