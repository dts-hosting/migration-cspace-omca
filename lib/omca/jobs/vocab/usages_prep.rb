# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module UsagesPrep
        module_function

        def desc = "Add normalized matchpoint to vocab__usages and "\
          "deduplicate on it, collating :fieldtable vals"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__usages,
              destination: :vocab__usages_prep
            },
            transformer: [Omca::Vocab.norm_xforms, xforms]
          )
        end

        def xforms
          Kiba.job_segment do
            transform Deduplicate::Table,
              field: :matchpoint,
              compile_uniq_fieldvals: true
          end
        end
      end
    end
  end
end
