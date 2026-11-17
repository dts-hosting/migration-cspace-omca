# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UsagesNewRefname
        module_function

        def job
          files = {
              source: :authorities__usages_final_source,
              destination: :authorities__usages_new_refname,
              lookup: :authorities__uniq_usage_new_lookup
            }
          unless Omca.ready_for_authority_merge?
            return Kiba::Extend::Jobs::NullJob.new(files: files)
          end

          Kiba::Extend::Jobs::Job.new(
            files: files,
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
