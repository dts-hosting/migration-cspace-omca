# frozen_string_literal: true

module Omca
  module Authorities
    class Usages
      def self.desc = "Write all authority refname usages, with table, row "\
        "id, and field"

      def self.call = new.call

      def call
        csv = CSV.open(
          Omca::Authorities.usages_path,
          "w",
          headers: Omca::Authorities.usages_headers,
          write_headers: true
        )
        Omca.orig_dirs.each { |dir| extract_from_files(dir, csv) }
        csv.close
        puts "Wrote all authority usages to #{Omca::Authorities.usages_path}"
      end

      private

      def extract_from_files(dir, csv)
        dirpath = File.join(Omca.datadir, "orig", dir)
        puts "Extracting from #{dirpath}"
        Dir.children(dirpath).each do |filename|
          extract_from_file(dir, filename, csv)
        end
      end

      def extract_from_file(dir, filename, csv)
        filepath = File.join(Omca.datadir, "orig", dir, filename)
        puts "Extracting from #{filepath}"
        base = {
          "tabletype" => dir,
          "table" => File.basename(filename, ".csv")
        }
        CSV.foreach(filepath, headers: true) do |row|
          extract_from_row(base.dup, row, csv)
        end
      end

      def extract_from_row(base, row, csv)
        base["id"] = row["id"]
        row.each { |field, val| extract_from_field(base.dup, field, val, csv) }
      end

      def extract_from_field(base, field, val, csv)
        return if val.blank?
        return unless val.start_with?("urn:cspace:")
        return if val[":vocabularies:"]
        return if field.end_with?("refname") ||
          field == "computedcurrentlocation"

        base["field"] = field
        termdata = Omca::Refname.add_parsed_detail(base, val)
        csv << termdata.values_at(*csv.headers)
      end
    end
  end
end
