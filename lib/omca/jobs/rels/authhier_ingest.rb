# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module AuthhierIngest
        module_function

        def job(source:, dest:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: source,
              destination: dest
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            contentfields = %i[term_type term_subtype narrower_term
              broader_term]

            transform Delete::FieldsExcept,
              fields: contentfields
            transform FilterRows::AllFieldsPopulated,
              action: :keep,
              fields: contentfields
          end
        end
      end
    end
  end
end
