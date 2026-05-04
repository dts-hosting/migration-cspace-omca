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

# rows[existing_id] = [] unless rows.key?(existing_id)
# rows[existing_id] << row

# nil

# def close
#   rows.each do |id, arr|
#     if arr.length == 1
#       yield arr.first
#     else
#       Omca::Util::IdDisambiguator.new(arr)
#         .call
#         .each { |row| yield row }
#     end
#   end
# end
