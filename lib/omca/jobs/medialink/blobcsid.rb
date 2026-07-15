# frozen_string_literal: true

module Omca
  module Jobs
    module Medialink
      module Blobcsid
        module_function

        def job(type:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :"fcarmerge_main__#{type}_common",
              destination: :"medialink__#{type}_blobcsid",
              lookup: [
                {
                  jobkey: :"refname_csid_lookup__#{type}",
                  lookup_on: :oldcsid
                },
                {
                  jobkey: :"new_db__#{type}_new_db_id_to_csid",
                  lookup_on: :newcsid
                }
              ]
            },
            transformer: xforms(type)
          )
        end

        def xforms(type)
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[id recordcsid blobcsid]

            transform Rename::Fields, fieldmap: {
              id: :oldid,
              recordcsid: :oldcsid
            }

            transform Merge::MultiRowLookup,
              lookup: send(:"refname_csid_lookup__#{type}"),
              keycolumn: :oldcsid,
              fieldmap: {newcsid: :newcsid}
            transform Merge::MultiRowLookup,
              lookup: send(:"new_db__#{type}_new_db_id_to_csid"),
              keycolumn: :newcsid,
              fieldmap: {id: :newdbid}
            transform Delete::FieldsExcept,
              fields: %i[id blobcsid]
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :blobcsid
          end
        end
      end
    end
  end
end
