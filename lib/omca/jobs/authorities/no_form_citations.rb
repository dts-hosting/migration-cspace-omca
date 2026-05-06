# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module NoFormCitations
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__usages,
              destination: :authorities__no_form_citations,
              lookup: [{
                jobkey: :main_rectype__citations_common,
                lookup_on: :shortidentifer
              }]
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::WithLambda,
              action: :keep,
              lambda: ->(row) do
                row[:vocab] == "citation" &&
                  row[:form].blank?
              end

            transform Merge::MultiRowLookup,
              lookup: main_rectype__citations_common,
              keycolumn: :termid,
              fieldmap: {form: :ingestid}

            transform FilterRows::FieldPopulated,
              action: :reject,
              field: :form
          end
        end
      end
    end
  end
end
