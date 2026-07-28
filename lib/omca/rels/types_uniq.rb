# frozen_string_literal: true

module Omca
  module Rels
    class TypesUniq
      include Omca::DynamicCsvJobable

      def self.desc = "Deduplicated rel types"

      def source = :rel_info__types_orig

      def destination = :rel_info__types_uniq

      def initialize
        @deduper = Set.new
      end

      def job_code
        deduplicate
        write
      end

      private

      attr_reader :deduper

      def deduplicate
        CSV.parse(File.read(source_path), **Kiba::Extend.csvopts)
          .each do |row|
            ends = [row[:subject], row[:object]].sort
              .join(" <-> ")
            type = case row[:reltype]
            when "affects" then "nonhier"
            when "hasbroader" then "hier"
            else
              raise("Unknown relationship type: #{row[:reltype]}")
            end
            deduper << [ends, type]
          end
      end

      def write
        CSV.open(
          destination_path, "w",
          headers: %i[rectypes reltype],
          write_headers: true
        ) do |csv|
          deduper.each { |row| csv << row }
        end
      end
    end
  end
end
