# frozen_string_literal: true

module Omca
  module Xforms
    class BigAuthMergeTerm
      KEEP_FIELDS = %i[recordcsid authority pos id termname termprefforlang
        termdisplayname termtype termstatus term_is_used
        shortidentifier]

      def initialize(table:, tabletype:, rectype:, mergerows:)
        @table = table
        @tabletype = tabletype
        @rectype = rectype
        @lookup = mergerows.group_by { |r| r[:termid] }
        @nomergerows = []
        @mergetargets = lookup.map { |k, v| [k, []] }.to_h
      end

      def process(row)
        id = row[:shortidentifier]
        if lookup.key?(id)
          mergetargets[id] << row
        else
          nomergerows << row
        end

        nil
      end

      def close
        lookup.map { |k, v| do_merge(k, v) }
          .flatten
          .each { |row| yield row }
        nomergerows.each { |row| yield row }
      end

      private

      attr_reader :table, :tabletype, :rectype, :lookup,
        :nomergerows, :mergetargets

      def do_merge(id, mergedata)
        terms = mergetargets[id]
        mergerow = mergedata.first
        return handle_collapsed(id, terms) if mergerow[:collapsingterm] == "y"

        newform = mergerow[:new_form]

        pref = terms.find { |term| term[:pos] == "0" }
        var = terms.find { |term| term[:termdisplayname] == newform }
        terms.map { |term| term[:pos].to_i }.max
        if var
          swap_forms(pref, var)
        else
          new_preferred(newform, pref, terms)
        end
        terms
      end

      def handle_collapsed(id, terms)
        binding.pry
      end

      def swap_forms(pref, var)
        pref[:pos] = var[:pos]
        var[:pos] = "0"
        var[:termstatus] = "accepted"
        var[:termtype] = "Descriptor"
        var[:termprefforlang] = "t"
        pref[:termtype] = "Alternate descriptor"
        pref[:termprefforlang] = "f"
      end

      def new_preferred(newform, pref, terms)
        terms.each { |t| increment_position(t) }
        terms.unshift(build_new_preferred(newform, pref))
        unpref_existing(pref)
      end

      def increment_position(t)
        expos = t[:pos].to_i
        newpos = expos + 1
        t[:pos] = newpos.to_s
      end

      def build_new_preferred(newform, pref)
        np = pref.dup
        binding.pry if np.nil?
        np[:pos] = "0"
        np[:termdisplayname] = newform
        np[:termname] = newform
        np[:termstatus] = "accepted"
        np[:termtype] = "Descriptor"
        np[:termprefforlang] = "t"
        np.each do |field, val|
          next if KEEP_FIELDS.include?(field)

          np[field] = ""
        end
        np
      end

      def unpref_existing(pref)
        pref[:termtype] = "Alternate descriptor"
        pref[:termprefforlang] = "f"
      end
    end
  end
end
