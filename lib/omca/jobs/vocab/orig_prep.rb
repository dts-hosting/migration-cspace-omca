# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module OrigPrep
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__orig,
              destination: :vocab__orig_prep
            },
            transformer: Omca::Vocab.norm_xforms
          )
        end
      end
    end
  end
end
