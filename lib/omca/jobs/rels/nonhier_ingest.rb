# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module NonhierIngest
        module_function

        def job(source:, dest:)
          files = {
            source: source,
            destination: dest
          }
          unless Kiba::Extend::Job.output?(source)
            return Kiba::Extend::Jobs::NullJob.new(files: files)
          end

          Kiba::Extend::Jobs::Job.new(
            files: files,
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            contentfields = %i[item1_id item2_id item1_type item2_type]

            transform Delete::FieldsExcept,
              fields: contentfields
            transform FilterRows::AllFieldsPopulated,
              action: :keep,
              fields: contentfields
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
