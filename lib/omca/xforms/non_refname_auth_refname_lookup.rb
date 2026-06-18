# frozen_string_literal: true

module Omca
  module Xforms
    class NonRefnameAuthRefnameLookup
      def initialize
        @headers = Omca::Authorities.non_refname_lookup_headers
          .map!(&:to_sym)
        @config = Omca::Authorities.non_refname_lookup_config
        @handlers = {}
        @rows_by_field = {}
      end

      def process(row)
        field = [row[:table], row[:field]]
        rows_by_field[field] = [] unless rows_by_field.key?(field)
        rows_by_field[field] << row
        nil
      end

      def close
        rows_by_field.map { |fdata, rows| lookup_for_field(fdata, rows) }
          .flatten
          .each { |row| yield row }
      end

      private

      attr_reader :headers, :config, :handlers, :rows_by_field

      def lookup_for_field(fdata, rows)
        config[fdata].each { |fsig| generate_handler(fsig) }
        rows.map { |row| lookup_row_val(config[fdata], row) }
      end

      def generate_handler(fsig)
        return if handlers.key?(fsig)

        handlers[fsig] = Omca::Authorities::LookupHandler.new(
          type: fsig[0], subtype: fsig[1]
        )
      end

      def lookup_row_val(auths, row)
        val = row[:value]
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
          row.to_h.merge({matchtype: "none", refname: nil})
        elsif matches.length == 1
          row.to_h.merge({
            matchtype: "single", refname: matches[0][:refname]
          })
        else
          m = select_most_populated_or_first(matches)
          row.to_h.merge({
            matchtype: "multi", refname: m[:refname]
          })
        end
      end

      def select_most_populated_or_first(matches)
        matches.map { |m| [m, m.compact.size] }
          .to_h
          .max_by { |a| a[1] }
          .first
      end
    end
  end
end
