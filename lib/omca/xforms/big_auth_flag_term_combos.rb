# frozen_string_literal: true

module Omca
  module Xforms
    class BigAuthFlagTermCombos
      def initialize
        @rtrows = {}
        @norm = Kiba::Extend::Utils::StringNormalizer.new(mode: :cspaceid)
      end

      def process(row)
        rt = row[:rectype]
        rtrows[rt] = [] unless rtrows.key?(rt)
        rtrows[rt] << row

        nil
      end

      def close
        rtrows.map { |rt, rows| flag_rtrows(rt, rows) }
          .flatten
          .each { |row| yield row }
      end

      private

      attr_reader :rtrows, :norm

      def rectype_terms(rectype)
        table = Omca::Mappings::Db.main_tables_by_rectype[rectype]
        Omca::Dependencies.ensure_preprocess(table)
        key = Omca::Dependencies.jobkey_for(:preprocess, table)
        path = Omca.registry.resolve(key).path
        CSV.parse(File.read(path), **Kiba::Extend.csvopts)
          .map { |r| [norm.call(r[:origpref]), r[:refname]] }
          .to_h
      end

      def flag_rtrows(rt, rows)
        rows.map { |row| flag_rtrow(row, rectype_terms(rt)) }
      end

      def flag_rtrow(row, terms)
        newform = norm.call(row[:new_form])
        if terms.key?(newform)
          row[:collapsingterm] = "y"
          row[:userefname] = terms[newform]
        else
          row[:collapsingterm] = "n"
          row[:userefname] = nil
        end
        row
      end
    end
  end
end
