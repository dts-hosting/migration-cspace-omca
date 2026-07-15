# frozen_string_literal: true

module Omca
  module Mappings
    module Doctype
      module_function

      def doctype_sheet = @doctype_sheet ||= get_sheet

      # @param rectype [String]
      # @return [String]
      def doctype_for(rectype)
        r = row_for(rectype)
        return unless r

        r["documenttype"]
      end

      # @param rectype [String]
      # @return [String]
      def term_type_for(rectype)
        r = row_for(rectype)
        return unless r

        r["term_type"]
      end

      # @param rectype [String]
      # @return [Hash]
      def row_for(rectype)
        doctype_sheet.find { |r| r["rectype"] == rectype }
      end

      def get_sheet
        Omca::Mappings.worksheet
          .sheet("doctype_mapping")
          .parse(headers: true)
      end
    end
  end
end
