# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module UsagesPrep
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__usages,
              destination: :vocab__usages_prep
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Cspace::NormalizeForID,
              source: :term,
              target: :normterm
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[vocabulary normterm],
              target: :matchpoint,
              delete_sources: false,
              delim: "%^&"
            transform Delete::Fields,
              fields: :normterm
          end
        end
      end
    end
  end
end
