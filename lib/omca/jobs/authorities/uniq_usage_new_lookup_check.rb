# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UniqUsageNewLookupCheck
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__uniq_usage_new_lookup_base,
              destination: :authorities__uniq_usage_new_lookup_check
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :reject,
              field: :newrefname
          end
        end
      end
    end
  end
end
