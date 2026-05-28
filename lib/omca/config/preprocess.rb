# frozen_string_literal: true

module Omca
  module Preprocess
    module_function

    extend Dry::Configurable

    setting :common_xforms,
      reader: true,
      default: nil,
      constructor: ->(default) do
        Kiba.job_segment do
          transform Delete::EmptyFields, report: true
          transform Omca::Xforms::DeurnVocabTerms
        end
      end
  end
end
