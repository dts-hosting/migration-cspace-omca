# frozen_string_literal: true

module Omca
  module Authorities
    class Usages
      include Omca::DynamicCsvJobable

      def self.desc = "Write all authority refname usages, with table, row "\
        "id, pos, and field"

      def source = :nuke_bom_dir_files

      # Uncomment this and comment out the above definition if you want VERY
      #   LARGE job graphs
      # def source = sources.map { |src| src.key.to_sym }

      def destination = :authorities__usages

      def job_code
        ensure_sources unless source.is_a?(Array)

        csv = CSV.open(
          destination_path,
          "w",
          headers: Omca::Authorities.usages_headers,
          write_headers: true
        )
        Omca.orig_dirs.each { |dir| extract_from_files(dir, csv) }
        csv.close
        puts "Wrote all authority usages to #{destination_path}"
      end

      private

      def ensure_sources
        sources.each do |src|
          unless File.exist?(src.path)
            Kiba::Extend::Command::Run.job(src.key.to_sym)
          end
        end
      end

      def sources = Kiba::Extend::Command::Jobs::TaggedOr.call(:nuke_bom)

      def extract_from_files(dir, csv)
        dirpath = File.join(Omca.datadir, "nuke_bom", dir)
        Dir.children(dirpath).each do |filename|
          extract_from_file(dir, filename, csv)
        end
      end

      def extract_from_file(dir, filename, csv)
        filepath = File.join(Omca.datadir, "nuke_bom", dir, filename)
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
        base["pos"] = row["pos"]
        row.each { |field, val| extract_from_field(base.dup, field, val, csv) }
      end

      def extract_from_field(base, field, val, csv)
        return if val.blank?
        return unless val.start_with?("urn:cspace:")
        return if val[":vocabularies:"]
        return if field.end_with?("refname")
        return if field == "computedcurrentlocation"

        base["field"] = field
        termdata = Omca::Refname.add_parsed_detail(base, val)
        csv << termdata.values_at(*csv.headers)
      end
    end
  end
end
