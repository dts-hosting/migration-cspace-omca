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
          transform Delete::EmptyFields, report: true

          if Omca::Mappers.authority?(rectype)
            transform Omca::Xforms::MergePreferredTerm,
              rectype: rectype
          else
            transform Omca::Xforms::IngestId,
              rectype: rectype
          end

          transform Omca::Xforms::DisambiguateIngestId
        end
      end
    end
  end
end
