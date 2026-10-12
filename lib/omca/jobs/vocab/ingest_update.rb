# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module IngestUpdate
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__diff,
              destination: :vocab__ingest_update
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :extrafields
            transform Delete::FieldsExcept,
              fields: %i[vocab in_target_form description termstatus source
                sourcepage]
            transform Rename::Field,
              from: :in_target_form,
              to: :term
          end
        end
      end
    end
  end
end
