# frozen_string_literal: true

module Omca
  module Rels
    class TypesUniq
      def self.desc = "Deduplicated rel types"

      def self.run = new.run

      def initialize
        @src_path = Omca::Rels.types_orig_path
        @out_path = Omca::Rels.types_uniq_path
        @deduper = Set.new
      end

      def run
        ensure_source
        deduplicate
        write
      end

      private

      attr_reader :src_path, :out_path, :deduper

      def ensure_source
        return if File.exist?(src_path)

        Kiba::Extend::Command::Run.job(:rel_info__types_orig)
      end

      def deduplicate
        CSV.parse(File.read(src_path), **Kiba::Extend.csvopts)
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
          out_path, "w",
          headers: %i[rectypes reltype],
          write_headers: true
        ) do |csv|
          deduper.each { |row| csv << row }
        end
        puts "Wrote to #{out_path}"
      end
    end
  end
end
