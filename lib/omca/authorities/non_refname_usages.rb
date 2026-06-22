# frozen_string_literal: true

module Omca
  module Authorities
    class NonRefnameUsages
      def self.desc = "Get non-refname values used in authority controlled "\
        "fields "

      def self.run = new.run

      def initialize
        @authfields = {}
      end

      def run
        unless File.exist?(Omca::Authorities.usages_path)
          Omca::Authorities::Usages.run
        end

        get_auth_fields
        csv = CSV.open(
          Omca::Authorities.non_refname_usages_path,
          "w",
          headers: Omca::Authorities.non_refname_usages_headers,
          write_headers: true
        )
        authfields.each do |tabledata, fields|
          extract_from_file(tabledata, fields, csv)
        end
        csv.close
      end

      private

      attr_reader :authfields

      def get_auth_fields
        CSV.foreach(Omca::Authorities.usages_path, headers: true) do |row|
          key = [row["tabletype"], row["table"]]
          authfields[key] = Set.new unless authfields.key?(key)
          authfields[key] << row["field"]
        end
      end

      def extract_from_file(tabledata, fields, csv)
        filepath = File.join(Omca.datadir, "orig", tabledata[0],
          "#{tabledata[1]}.csv")
        puts "Extracting from #{filepath}"
        base = {
          "tabletype" => tabledata[0],
          "table" => tabledata[1]
        }
        CSV.foreach(filepath, headers: true) do |row|
          extract_from_fields(base.dup, row, fields, csv)
        end
      end

      def extract_from_fields(base, row, fields, csv)
        base["id"] = row["id"]
        base["recordcsid"] = row["recordcsid"]
        fields.each { |field| extract_from_field(base.dup, row, field, csv) }
      end

      def extract_from_field(base, row, field, csv)
        val = row[field]
        return if val.blank?
        return if val.start_with?("urn:cspace:")
        return if val[":vocabularies:"]
        return if field.end_with?("refname") ||
          field == "computedcurrentlocation"

        base["field"] = field
        base["value"] = val
        csv << base.values_at(*csv.headers)
      end
    end
  end
end
