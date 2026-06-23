# frozen_string_literal: true

module Omca
  module Xforms
    class UnlinkedAuthRefnameLookup
      def initialize
        @headers = %i[authority vocab index]
        @handlers = {}
        @rows_by_auth = {}
      end

      def process(row)
        auth = [row[:authority], row[:vocab]]
        rows_by_auth[auth] = [] unless rows_by_auth.key?(auth)
        rows_by_auth[auth] << row
        nil
      end

      def close
        rows_by_auth.map { |auth, rows| lookup_for_auth(auth, rows) }
          .flatten
          .each { |row| yield row }
      end

      private

      attr_reader :headers, :handlers, :rows_by_auth

      def lookup_for_auth(auth, rows)
        generate_handler(auth)
        rows.map { |row| lookup_row_val(auth, row) }
      end

      def generate_handler(auth)
        return if handlers.key?(auth)

        rectype = Omca::Mappings::Db.rectype_for_table("#{auth[0]}_common")
        handlers[auth] = Omca::Authorities::LookupHandler.new(
          type: rectype, subtype: auth[1]
        )
      end

      def lookup_row_val(auth, row)
        val = row[:form]
        prefmatches = handlers[auth].by_termdisplayname(
          val, type: :pref
        ).flatten

        unless prefmatches.empty?
          return prepare_for_write(prefmatches, row)
        end

        nonprefmatches = handlers[auth].by_termdisplayname(
          val, type: :nonpref
        ).flatten
        prepare_for_write(nonprefmatches, row)
      end

      def prepare_for_write(matches, row)
        if matches.empty?
          row.to_h.merge({matchtype: "none", refname: nil})
        elsif matches.length == 1
          row.to_h.merge({
            matchtype: "single",
            refname: matches[0][:refname],
            preftermrecordcsid: matches[0][:recordcsid]
          })
        else
          m = select_most_populated_or_first(matches)
          row.to_h.merge({
            matchtype: "multi",
            refname: m[:refname],
            preftermrecordcsid: m[:recordcsid]
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
