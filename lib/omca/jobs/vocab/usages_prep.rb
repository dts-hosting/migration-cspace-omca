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
            transformer: Omca::Vocab.norm_xforms
          )
        end
      end
    end
  end
end
