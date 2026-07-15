# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UsagesNewRefname
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: Omca.auth_usages,
              destination: :authorities__usages_new_refname,
              lookup: :authorities__uniq_usage_new_lookup
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::Fields,
              fields: %i[authority vocab termid form index]
            transform Rename::Field,
              from: :refname,
              to: :oldrefname
            transform Merge::MultiRowLookup,
              lookup: authorities__uniq_usage_new_lookup,
              keycolumn: :oldrefname,
              fieldmap: {refname: :newrefname}
            transform Delete::Fields,
              fields: :oldrefname
          end
        end
      end
    end
  end
end
