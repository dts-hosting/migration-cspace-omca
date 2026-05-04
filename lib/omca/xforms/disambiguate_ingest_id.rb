# frozen_string_literal: true

module Omca
  module Xforms
    class DisambiguateIngestId
      def initialize
        @field = Omca.ingestid_field
        @rows = {}
      end

      def process(row)
        existing_id = row[field]

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

      attr_reader :field, :rows
    end
  end
end
