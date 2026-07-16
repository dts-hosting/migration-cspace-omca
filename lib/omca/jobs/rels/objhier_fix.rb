# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module ObjhierFix
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :rels_source_hier__collectionobject_collectionobject,
              destination: :rels_fix_hier__collectionobject_collectionobject,
              lookup: {
                jobkey: :refname_csid_lookup__collectionobject,
                lookup_on: :oldcsid
              }
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Merge::MultiRowLookup,
              lookup: refname_csid_lookup__collectionobject,
              keycolumn: :narrower,
              fieldmap: {narrower_object_number: :objectnumber}

            transform Merge::MultiRowLookup,
              lookup: refname_csid_lookup__collectionobject,
              keycolumn: :broader,
              fieldmap: {broader_object_number: :objectnumber}

            transform Rename::Field,
              from: :relationshipmetatype,
              to: :relationship_type
          end
        end
      end
    end
  end
end
