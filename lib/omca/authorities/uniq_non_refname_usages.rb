# frozen_string_literal: true

module Omca
  module Authorities
    class UniqNonRefnameUsages
      def self.desc = "Write one row per used non-refname value in
        authority-controlled field, with count of usages."

      def self.call = new.call

      def initialize
        @srcpath = Omca::Authorities.non_refname_usages_path
        @outpath = Omca::Authorities.uniq_non_refname_usages_path
        @counter = {}
      end

      def call
        populate_counter
        write_csv
      end

      private

      attr_reader :srcpath, :outpath, :counter

      def populate_counter
        File.open(srcpath) do |file|
          CSV.foreach(file, headers: true) do |row|
            rowhash = row.to_h
            rowhash.delete("id")
            counter[rowhash] = 0 unless counter.key?(rowhash)
            counter[rowhash] += 1
          end
        end
      end

      def write_csv
        CSV.open(
          outpath,
          "w",
          headers: Omca::Authorities.uniq_non_refname_usages_headers,
          write_headers: true
        ) do |csv|
          counter.each do |rowhash, ct|
            data = rowhash.merge({"usagect" => ct})
            csv << data.values_at(*csv.headers)
          end
        end
        puts "Wrote unique authority usages to #{outpath}"
      end
    end
  end
end
