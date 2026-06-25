# frozen_string_literal: true

module Omca
  module Xforms
    class DisambiguateIngestId
      def initialize(authority: false)
        @authority = authority
        @field = Omca.ingestid_field
        @normalizer = Kiba::Extend::Utils::StringNormalizer.new(
          mode: :cspaceid
        )
        @rows = {}
      end

      def process(row)
        if authority
          process_authority(row)
        else
          process_non_authority(row)
        end
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

      attr_reader :authority, :field, :normalizer, :rows

      def process_authority(row)
        used = row[Omca::Authorities.used_tag_field]
        if used == "n"
          rows[row[:id]] = [row]
        else
          existing_id = row[field]
          norm = normalizer.call(existing_id)
          rows[norm] = [] unless rows.key?(norm)
          rows[norm] << row
        end
        nil
      end

      def process_non_authority(row)
        existing_id = row[field]
        rows[existing_id] = [] unless rows.key?(existing_id)
        rows[existing_id] << row

        nil
      end
    end
  end
end
