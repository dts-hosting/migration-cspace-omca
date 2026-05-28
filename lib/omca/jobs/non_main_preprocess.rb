# frozen_string_literal: true

module Omca
  module Jobs
    module NonMainPreprocess
      module_function

      # @param sources [Array<Symbol>]
      # @param dest [Symbol]
      # @param rectype [String]
      # @param tabletype [String]
      def job(source:, dest:, rectype:, tabletype:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest
          },
          transformer: [
            xforms(rectype, tabletype),
            Omca::Preprocess.common_xforms
          ]
        )
      end

      def xforms(rectype, tabletype)
        Kiba.job_segment do
          if Omca::Mappers.authority?(rectype) &&
              tabletype == "repeatable_field_group"
            transform Omca::Xforms::InheritUnusedAuthorityTags,
              rectype: rectype
          end
        end
      end
    end
  end
end
