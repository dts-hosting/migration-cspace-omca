# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module InTargetPrep
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__in_target,
              destination: :vocab__in_target_prep
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
              sources: %i[vocab normterm],
              target: :matchpoint,
              delete_sources: false,
              delim: "%^&"
            transform Delete::FieldsExcept,
              fields: %i[term matchpoint vocab]
          end
        end
      end
    end
  end
end
