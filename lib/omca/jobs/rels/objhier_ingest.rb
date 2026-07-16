# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module ObjhierIngest
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :rels_fix_hier__collectionobject_collectionobject,
              destination: :rels_ingest_hier__collectionobject_collectionobject
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::Fields,
              fields: %i[narrower broader]
            transform FilterRows::AllFieldsPopulated,
              action: :keep,
              fields: %i[narrower_object_number broader_object_number]
          end
        end
      end
    end
  end
end
