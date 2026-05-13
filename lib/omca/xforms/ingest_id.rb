# frozen_string_literal: true

module Omca
  module Xforms
    class IngestId
      def initialize(rectype:)
        @rectype = rectype
        @target = Omca.ingestid_field
        @idfield = Omca::Mappers.id_field_lookup[rectype]
        fail("No id field for #{rectype}") unless @idfield
      end

      def process(row)
        row[target] = row[idfield]

        row
      end

      private

      attr_reader :rectype, :target, :idfield
    end
  end
end
