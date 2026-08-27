# frozen_string_literal: true

module Omca
  module Jobs
    module AuthVocabRemap
      module EthcultureUniqUsages
        module_function

        def desc = "Extract concept/ethculture rows; Will use as "\
          "data source for merging new rows into concepts_common"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :auth_vocab_remap__uniq_usages,
              destination: :auth_vocab_remap__ethculture_uniq_usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :vocab,
              value: "ethculture"
          end
        end
      end
    end
  end
end
