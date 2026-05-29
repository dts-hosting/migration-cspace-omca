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
          transform Clean::StripFields,
            fields: :all
          transform Clean::RegexpFindReplaceFieldVals,
            fields: :all,
            find: /\|/,
            replace: "\u{2758}"
        end
      end
  end
end
