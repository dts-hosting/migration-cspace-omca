# frozen_string_literal: true

module Omca
  module Jobs
    module MainPreprocess
      module_function

      # @param sources [Array<Symbol>]
      # @param dest [Symbol]
      # @param rectype [String]
      def job(source:, dest:, rectype:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest
          },
          transformer: xforms(rectype)
        )
      end

      def xforms(rectype)
        Kiba.job_segment do
          if Omca::Mappers.authority?(rectype)
            transform Omca::Xforms::TagUnusedAuthorityTerms,
              rectype: rectype
            transform Omca::Xforms::MergePreferredTerm,
              rectype: rectype
            transform Delete::Fields,
              fields: %i[sas proposed deprecated rev inauthority]
          else
            transform Omca::Xforms::IngestId,
              rectype: rectype
          end

          transform Omca::Xforms::DisambiguateIngestId
          transform Delete::EmptyFields, report: true
        end
      end
    end
  end
end
