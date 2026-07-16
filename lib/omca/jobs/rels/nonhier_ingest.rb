# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module NonhierIngest
        module_function

        def job(source:, dest:)
          unless Kiba::Extend::Job.output?(source)
            return Kiba::Extend::Jobs::NullJob.new(source)
          end

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
            contentfields = %i[item1_id item2_id item1_type item2_type]

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
