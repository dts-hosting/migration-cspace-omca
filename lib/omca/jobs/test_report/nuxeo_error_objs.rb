# frozen_string_literal: true

module Omca
  module Jobs
    module TestReport
      module NuxeoErrorObjs
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :rels_source_nonhier__collectionobject_group,
              destination: :test_report__nuxeo_error_objs,
              lookup: {
                jobkey: :preprocess_main__collectionobjects_common,
                lookup_on: :recordcsid
              }
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :objectcsid,
              value: "959773cc-8080-4603-9705"
            transform Merge::MultiRowLookup,
              lookup: preprocess_main__collectionobjects_common,
              keycolumn: :subjectcsid,
              fieldmap: {
                objectnumber: :objectnumber,
                computedcurrentlocation: :computedcurrentlocation
              }
          end
        end
      end
    end
  end
end
