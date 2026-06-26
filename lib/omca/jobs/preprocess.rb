# frozen_string_literal: true

module Omca
  module Jobs
    module Preprocess
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
          transformer: [
            get_xforms(rectype, tabletype),
            Omca::Preprocess.common_xforms
          ].compact
        )
      end

      def get_xforms(rectype, tabletype)
        if tabletype == "main" && Omca::Mappers.authority?(rectype)
          main_auth_xforms(rectype)
        elsif tabletype == "main"
          main_non_auth_xforms(rectype)
        elsif Omca::Mappers.authority?(rectype)
          non_main_auth_xforms(rectype)
        else
          non_main_non_auth_xforms
        end
      end

      def main_auth_xforms(rectype)
        Kiba.job_segment do
          transform Omca::Xforms::MergePreferredTerm,
            rectype: rectype
          transform Delete::Fields,
            fields: %i[sas proposed deprecated rev inauthority]
        end
      end

      def main_non_auth_xforms(rectype)
        Kiba.job_segment do
          transform Omca::Xforms::IngestId,
            rectype: rectype
          transform Omca::Xforms::DisambiguateIngestId
        end
      end

      def non_main_auth_xforms(rectype)
        Kiba.job_segment do
          transform Omca::Xforms::InheritTermid,
            rectype: rectype
        end
      end

      def non_main_non_auth_xforms = nil
    end
  end
end
