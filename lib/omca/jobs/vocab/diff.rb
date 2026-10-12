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
              lookup: %i[
                vocab__in_target_prep
                vocab__orig_prep
              ]
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Merge::MultiRowLookup,
              lookup: vocab__in_target_prep,
              keycolumn: :matchpoint,
              fieldmap: {in_target_form: :term}
            transform Merge::ConstantValueConditional,
              fieldmap: {exist: "y"},
              condition: ->(row) { !row[:in_target_form].blank? }
            transform Merge::ConstantValueConditional,
              fieldmap: {different_form: "y"},
              condition: ->(row) do
                return false if row[:exist].blank?
                return false if row[:term] == row[:in_target_form]

                true
              end
            transform Merge::MultiRowLookup,
              lookup: vocab__orig_prep,
              keycolumn: :matchpoint,
              fieldmap: {
                description: :description,
                termstatus: :termstatus,
                source: :source,
                sourcepage: :sourcepage
              }
            transform Merge::ConstantValueConditional,
              fieldmap: {extrafields: "y"},
              condition: ->(row) do
                %i[description termstatus source sourcepage].any? do |f|
                  !row[f].blank?
                end
              end
          end
        end
      end
    end
  end
end
