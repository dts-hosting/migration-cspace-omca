# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module FixMalformedUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__usages,
              destination: :authorities__fix_malformed_usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Omca::Xforms::MalformedConceptRefnames

            transform FilterRows::WithLambda,
              action: :reject,
              lambda: ->(row) do
                row[:vocab] == "citation" &&
                  row[:form].blank?
              end
          end
        end
      end
    end
  end
end
