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
            transformer: Omca::Vocab.norm_xforms
          )
        end
      end
    end
  end
end
