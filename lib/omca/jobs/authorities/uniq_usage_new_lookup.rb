# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UniqUsageNewLookup
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__uniq_usage_new_lookup_base,
              destination: :authorities__uniq_usage_new_lookup
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[refname newrefname]
            transform Rename::Field,
              from: :refname,
              to: :oldrefname
          end
        end
      end
    end
  end
end
