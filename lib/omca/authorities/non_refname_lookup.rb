# frozen_string_literal: true

module Omca
  module Authorities
    class NonRefnameLookup
      def self.desc = "Look for authority record matching non-refname "\
        "values in the appropriate authority vocabularies for the fields "\
        "where the values are used. Writes out file that can be used as "\
        "supplied lookup for fixes made to the tables where these values "\
        "occur"

      def self.call = new.call

      def initialize
        @srcpath = Omca::Authorities.uniq_non_refname_usages_path
        @outpath = Omca::Authorities.non_refname_lookup_path
        @config = Omca::Authorities.non_refname_lookup_config
        @headers = Omca::Authorities.non_refname_lookup_headers
        @handlers = {}
        @outrows = []
      end

      def call
        unless File.exist?(srcpath)
          Omca::Authorities::UniqNonRefnameUsages.call
        end

        rows_by_field.each { |fdata, rows| lookup_for_field(fdata, rows) }
        CSV.open(outpath, "w", headers: headers, write_headers: true) do |csv|
          outrows.each { |r| csv << r.values_at(*headers) }
        end
        puts "Wrote to #{outpath}"
      end

      private

      attr_reader :srcpath, :outpath, :config, :headers, :handlers, :outrows

      def rows_by_field = CSV.parse(File.read(srcpath), headers: true)
        .group_by { |r| [r["table"], r["field"]] }

      def lookup_for_field(fdata, rows)
        config[fdata].each { |fsig| generate_handler(fsig) }
        rows.each { |row| lookup_row_val(config[fdata], row) }
      end

      def lookup_row_val(auths, row)
        val = row["value"]
        prefmatches = auths.map do |auth|
          handlers[auth].by_termdisplayname(val, type: :pref)
        end.flatten
        unless prefmatches.empty?
          return prepare_for_write(prefmatches, row)
        end

        nonprefmatches = auths.map do |auth|
          handlers[auth].by_termdisplayname(val, type: :nonpref)
        end.flatten
        prepare_for_write(nonprefmatches, row)
      end

      def prepare_for_write(matches, row)
        if matches.empty?
          outrows << row.to_h.merge({"matchtype" => "none"})
        elsif matches.length == 1
          outrows << row.to_h.merge({
            "matchtype" => "single", "refname" => matches[0]["refname"]
          })
        else
          m = select_most_populated_or_first(matches)
          outrows << row.to_h.merge({
            "matchtype" => "multi", "refname" => m["refname"]
          })
        end
      end

      def select_most_populated_or_first(matches)
        matches.map { |m| [m, m.compact.size] }
          .to_h
          .max_by { |a| a[1] }
          .first
      end

      def generate_handler(fsig)
        return if handlers.key?(fsig)

        handlers[fsig] = Omca::Authorities::LookupHandler.new(
          type: fsig[0], subtype: fsig[1]
        )
      end
    end
  end
end
