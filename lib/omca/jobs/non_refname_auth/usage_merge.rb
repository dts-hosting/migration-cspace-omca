# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      module UsageMerge
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__usages,
              destination: :non_refname_auth__usage_merge,
              lookup: [{
                jobkey: :non_refname_auth__not_matched_provided,
                lookup_on: :nonrefnameindex
              },
                {
                  jobkey: :non_refname_auth__refname_looked_up,
                  lookup_on: :nonrefnameindex
                }]
            },
            transformer: [
              Omca::Authorities.add_non_refname_index,
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Merge::MultiRowLookup,
              lookup: non_refname_auth__not_matched_provided,
              keycolumn: :nonrefnameindex,
              fieldmap: {provided: :refname}
            transform Merge::MultiRowLookup,
              lookup: non_refname_auth__refname_looked_up,
              keycolumn: :nonrefnameindex,
              fieldmap: {lookedup: :refname}
            transform FilterRows::AnyFieldsPopulated,
              action: :keep,
              fields: %i[provided lookedup]
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[provided lookedup],
              target: :refname,
              delete_sources: true,
              delim: " "
            transform Delete::Fields,
              fields: %i[recordcsid value nonrefnameindex]
            transform do |row|
              refname = row[:refname]
              Omca::Refname.add_parsed_detail(row, refname, sym: true)
              row
            end
          end
        end
      end
    end
  end
end
