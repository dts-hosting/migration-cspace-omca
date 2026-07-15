# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module TypesModified
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :rel_info__types_uniq,
              destination: :rel_info__types_modified
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Rename::Field,
              from: :rectypes,
              to: :source
            transform Split::IntoMultipleColumns,
              field: :source,
              sep: " <-> ",
              max_segments: 2
            transform Clean::RegexpFindReplaceFieldVals,
              fields: %i[source0 source1],
              find: /item$/,
              replace: ""
            transform Copy::Field,
              from: :source0,
              to: :target0
            transform Copy::Field,
              from: :source1,
              to: :target1
            transform Clean::RegexpFindReplaceFieldVals,
              fields: %i[target0 target1],
              find: /objectexit/,
              replace: "exit"
            transform Omca::Xforms::AddMigReltypes
            transform CombineValues::FullRecord
            transform Deduplicate::Table,
              field: :index,
              delete_field: true
          end
        end
      end
    end
  end
end
