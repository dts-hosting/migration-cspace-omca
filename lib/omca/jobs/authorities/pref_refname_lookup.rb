# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module PrefRefnameLookup
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: sources,
              destination: :authorities__pref_refname_lookup
            },
            transformer: xforms
          )
        end

        def sources
          Omca::Mappings::Fields.skeleton_rectypes
            .select { |rectype| Omca::Mappers.authority?(rectype) }
            .map do |rectype|
              table = Omca::Mappings::Db.main_tables_by_rectype[rectype]
              :"fcarmerge_main__#{table}"
            end.select { |job| Kiba::Extend::Job.output?(job) }
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[authority shortidentifier refname]
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[authority shortidentifier],
              target: :auth_id_index,
              delete_sources: true,
              delim: " "
          end
        end
      end
    end
  end
end
