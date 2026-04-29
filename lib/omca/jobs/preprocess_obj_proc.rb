# frozen_string_literal: true

module Omca
  module Jobs
    module PreprocessObjProc
      module_function

      # @param sources [Array<Symbol>]
      # @param dest [Symbol]
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
          transform Omca::Xforms::IngestId,
            rectype: rectype
        end
      end
    end
  end
end
