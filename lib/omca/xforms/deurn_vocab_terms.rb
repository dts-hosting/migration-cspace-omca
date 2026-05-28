# frozen_string_literal: true

module Omca
  module Xforms
    class DeurnVocabTerms
      def process(row)
        row.map { |field, val| deurn_val(field, val) }
          .to_h
      end

      private

      def deurn_val(field, val)
        return [field, val] if val.blank?
        return [field, val] unless Omca::Refname.vocabulary_term?(val)

        [field, Omca::Refname.deurn(val)]
      end
    end
  end
end
