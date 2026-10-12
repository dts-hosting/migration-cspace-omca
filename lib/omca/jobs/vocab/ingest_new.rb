# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module IngestNew
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__diff,
              destination: :vocab__ingest_new
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :reject,
              field: :exist
            transform Delete::Fields, fields: %i[matchpoint exist]
          end
        end
      end
    end
  end
end
