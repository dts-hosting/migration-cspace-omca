# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module FixUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authority_ref__usages,
              destination: :authorities__fix_usages
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

            removals = Omca::Mappings::Fields.usage_removals
            transform do |row|
              next if removals.include?([row[:table], row[:field]])

              row
            end

            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[authority vocab termid],
              target: :index,
              delete_sources: false,
              delim: " "
          end
        end
      end
    end
  end
end
