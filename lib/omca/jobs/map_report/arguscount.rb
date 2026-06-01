# frozen_string_literal: true

module Omca
  module Jobs
    module MapReport
      module Arguscount
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :preprocess_addtl_fields__collectionobjects_omca,
              destination: :map_report__arguscount
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[arguscount]
            transform FilterRows::AnyFieldsPopulated,
              action: :keep,
              fields: %i[arguscount]
            transform Deduplicate::Table,
              field: :arguscount,
              include_occs: true
          end
        end
      end
    end
  end
end
