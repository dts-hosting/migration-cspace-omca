# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module Diff
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__usages_prep,
              destination: :vocab__diff,
              lookup: :vocab__in_target_prep
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Merge::MultiRowLookup,
              lookup: vocab__in_target_prep,
              keycolumn: :matchpoint,
              fieldmap: {in_target: :term}
            transform FilterRows::FieldPopulated,
              action: :reject,
              field: :in_target
          end
        end
      end
    end
  end
end
