# frozen_string_literal: true

module Omca
  module Jobs
    module NonRefnameAuth
      module ClientCleanup
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :non_refname_auth__usages,
              destination: :non_refname_auth__client_cleanup,
              lookup: {
                jobkey: :non_refname_auth__not_matched_client_cleanup,
                lookup_on: :nonrefnameindex
              }
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
              lookup: non_refname_auth__not_matched_client_cleanup,
              keycolumn: :nonrefnameindex,
              fieldmap: {match: :nonrefnameindex}
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :match
            transform Delete::Fields,
              fields: :match
            transform do |row|
              next row unless row[:field] == "item"

              row[:field] = row[:table].split("_").last
              row
            end
            transform Sort::ByFieldValue,
              field: :nonrefnameindex,
              mode: :string
            transform Delete::FieldsExcept,
              fields: %i[recordcsid field value]
          end
        end
      end
    end
  end
end
