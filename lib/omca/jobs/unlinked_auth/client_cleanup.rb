# frozen_string_literal: true

module Omca
  module Jobs
    module UnlinkedAuth
      module ClientCleanup
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_usages,
              destination: :unlinked_auth__client_cleanup,
              lookup: {
                jobkey: :unlinked_auth__refname_fcar_fail,
                lookup_on: :index
              }
            },
            transformer: [
              Omca::Authorities.add_term_index,
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Merge::MultiRowLookup,
              lookup: unlinked_auth__refname_fcar_fail,
              keycolumn: :index,
              fieldmap: {match: :index},
              delim: Omca.delim
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :match
            transform Delete::Fields,
              fields: :match
            transform Omca::Xforms::MergeUsingRecCsids
            transform do |row|
              field = row[:field]
              next row unless field == "item"

              row[:field] = row[:table].split("_").last
              row
            end
            transform Delete::Fields,
              fields: %i[tabletype table id termid refname index]
          end
        end
      end
    end
  end
end
