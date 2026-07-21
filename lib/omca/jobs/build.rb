# frozen_string_literal: true

module Omca
  module Jobs
    module Build
      module_function

      # @param source [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param tabletype [String]
      # @param rectype [String]
      def job(source:, dest:, table:, tabletype:, rectype:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest
          },
          transformer: xforms(tabletype, table)
        )
      end

      def xforms(tabletype, table)
        Kiba.job_segment do
          case table
          when "titlegroup"
            transform Omca::Xforms::AddSubgroup,
              src: :authmerge_subgroup__titletranslationsubgroup
          when "measuredpartgroup"
            transform Omca::Xforms::AddSubgroup,
              src: :authmerge_extension_subgroup__dimensionsubgroup
          end
        end
      end
    end
  end
end
