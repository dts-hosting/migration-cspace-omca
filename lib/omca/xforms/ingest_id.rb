# frozen_string_literal: true

module Omca
  module Xforms
    class IngestId
      def initialize(rectype:)
        @rectype = rectype
        @target = Omca.ingestid_field
        @idfield = Omca::Mappers.id_field_lookup[rectype]
        fail("No id field for #{rectype}") unless @idfield
        @rows = {}
      end

      def process(row)
        existing_id = row[idfield]
        row[target] = existing_id
        rows[existing_id] = [] unless rows.key?(existing_id)
        rows[existing_id] << row

        nil
      end

      def close
        rows.each do |id, arr|
          if arr.length == 1
            yield arr.first
          else
            Omca::Util::IdDisambiguator.new(arr)
              .call
              .each { |row| yield row }
          end
        end
      end

      private

      attr_reader :rectype, :target, :rows, :idfield
    end
  end
end
