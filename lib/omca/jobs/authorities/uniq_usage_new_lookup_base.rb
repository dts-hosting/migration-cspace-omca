# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module UniqUsageNewLookupBase
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: Omca.auth_uniq_usages,
              destination: :authorities__uniq_usage_new_lookup_base,
              lookup: %i[
                authorities__pref_refname_lookup
                authorities__new_refname_lookup
              ]
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[vocab termid],
              target: :auth_id_index,
              delete_sources: false,
              delim: " "

            transform Merge::MultiRowLookup,
              lookup: authorities__pref_refname_lookup,
              keycolumn: :auth_id_index,
              fieldmap: {prefrefname: :refname}

            transform Merge::MultiRowLookup,
              lookup: authorities__new_refname_lookup,
              keycolumn: :prefrefname,
              fieldmap: {newrefname: :newrefname}
          end
        end
      end
    end
  end
end
