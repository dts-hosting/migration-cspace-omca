# frozen_string_literal: true

module Omca
  module Jobs
    module Strip
      module_function

      # @param sources [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param rectype [String]
      # @param tabletype [String]
      def job(source:, dest:, table:, rectype:, tabletype:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest
          },
          transformer: xforms
        )
      end

      def xforms
        Kiba.job_segment do
          transform Clean::StripFields, fields: :all
          transform Clean::RegexpFindReplaceFieldVals,
            fields: :all,
            find: /  +/,
            replace: " "
        end
      end
    end
  end
end
